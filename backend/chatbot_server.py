from flask import Blueprint, request, jsonify
import os
import re
from appointment_models import ChatHistory, ScanHistory
from medical_kb import MEDICAL_KNOWLEDGE

# Short disclaimer - clean, 3 words
DISCLAIMER = "Consult a doctor."

# Create Blueprint
chatbot_bp = Blueprint('chatbot_bp', __name__)

# ----- LOAD GROQ CLIENT (Free - uses Llama 3) -----
groq_client = None
try:
    from groq import Groq
    api_key = os.getenv("GROQ_API_KEY")
    if api_key:
        groq_client = Groq(api_key=api_key)
        print("✅ Groq AI client initialized (Free Llama 3)!")
    else:
        print("⚠️ No Groq key - running in Local Expert Mode")
except Exception as e:
    print(f"⚠️ Groq not available: {e}")


def clean_text(text):
    """Remove markdown bold/italic markers so they don't show as raw ** in the app"""
    text = re.sub(r'\*\*(.*?)\*\*', r'\1', text)  # **bold** -> bold
    text = re.sub(r'\*(.*?)\*', r'\1', text)       # *italic* -> italic
    text = re.sub(r'#{1,6}\s?', '', text)           # ### headers -> plain
    return text.strip()


def cleanup_old_history(user_id):
    """Keep only the last 20 messages per user to avoid DB bloat"""
    try:
        all_msgs = list(ChatHistory.objects(userId=user_id).order_by('-timestamp'))
        if len(all_msgs) > 20:
            to_delete = all_msgs[20:]
            for msg in to_delete:
                msg.delete()
    except:
        pass


def get_ai_response(question, history=[]):
    """Fallback to Groq (FREE Llama 3) for general skin questions"""
    if not groq_client:
        return None
    try:
        system_prompt = (
            "You are 'Skin AI', a friendly medical assistant for a skin health app. "
            "You are an expert in THREE main areas:\n"
            "1. MELANOMA - skin cancer detection, moles, ABCDE rule, sun damage, biopsy, stages.\n"
            "2. ACNE / SKIN - pimples, blackheads, oily skin, skincare routines, skin tips, dark spots.\n"
            "3. WOUNDS - cuts, bleeding, infections, first aid, bandaging, healing.\n"
            "Answer any question on these topics in a clear, friendly, and helpful way. "
            "Keep responses short (3-5 sentences). Do NOT use ** or # or any markdown. "
            "Always end with: Consult a doctor for personal advice."
        )
        messages = [{"role": "system", "content": system_prompt}]
        # Only pass last 5 history items for context
        for h in history[-5:]:
            messages.append(h)
        messages.append({"role": "user", "content": question})
        response = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=messages,
            max_tokens=200,
            temperature=0.7
        )
        answer = response.choices[0].message.content.strip()
        return clean_text(answer)
    except Exception as e:
        print(f"[Groq Error]: {str(e)}")
        return None


def faq_search(question):
    """Search all FAQs by word overlap"""
    q_words = set(question.lower().replace("?", "").split())
    best_match = None
    best_score = 0

    for key in MEDICAL_KNOWLEDGE:
        for faq in MEDICAL_KNOWLEDGE[key]['faq']:
            faq_words = set(faq['q'].lower().replace("?", "").split())
            ignore = {"the", "a", "an", "is", "it", "do", "i", "me", "my", "for", "of", "to", "and", "or", "how", "what", "when", "why", "should"}
            overlap = (q_words - ignore) & (faq_words - ignore)
            score = len(overlap)
            if score > best_score:
                best_score = score
                best_match = (key, faq)

    if best_score >= 2 and best_match:
        key, faq = best_match
        # Return only the answer, not the question again
        return f"{faq['a']} {DISCLAIMER}"
    return None


def get_expert_response(question, user_id="guest"):
    q = question.lower().strip()

    # 1. Greetings
    if q in ["hi", "hello", "hey", "hola", "help"]:
        return ("Hello! I am Skin AI, your personal skin health assistant. "
                "I can help you with Melanoma, Acne, Wounds, and general skin care tips. "
                "Ask me anything or tap a question below!")

    # 2. Check for Scan Context (Personalized)
    if any(k in q for k in ["my scan", "my result", "what do i have", "my report", "latest scan"]):
        try:
            latest_scan = ScanHistory.objects(userId=user_id).order_by('-timestamp').first()
            if latest_scan:
                pred = latest_scan.prediction.lower()
                conf = latest_scan.confidence

                category = None
                if "acne" in pred or "clear" in pred:
                    category = "acne"
                elif "mela" in pred or "nevus" in pred or "carcinoma" in pred or "keratosis" in pred:
                    category = "melanoma"

                response = f"Your latest scan result is {latest_scan.prediction} with {conf}% confidence. "

                if category and category in MEDICAL_KNOWLEDGE:
                    kb = MEDICAL_KNOWLEDGE[category]
                    response += f"{kb['definition']} {DISCLAIMER}"
                else:
                    response += DISCLAIMER
                return response
            else:
                return "You haven't performed any scans yet. Please use the Acne Scanner or Melanoma Scanner to get your personalized results!"
        except Exception as e:
            print(f"Scan lookup error: {e}")

    # 3. Direct FAQ Match
    faq_result = faq_search(question)
    if faq_result:
        return faq_result

    # 4. Keyword Match in Knowledge Base
    for key in MEDICAL_KNOWLEDGE:
        if key in q:
            kb = MEDICAL_KNOWLEDGE[key]

            if any(w in q for w in ["symptom", "sign", "look like", "appear", "notice"]):
                return "Symptoms of " + key.capitalize() + ": " + ", ".join(kb['symptoms']) + ". " + DISCLAIMER

            if any(w in q for w in ["cause", "reason", "trigger"]):
                return "Causes of " + key.capitalize() + ": " + kb['causes'] + " " + DISCLAIMER

            if any(w in q for w in ["treat", "cure", "fix", "medicine", "remedy", "heal"]):
                return "Treatment for " + key.capitalize() + ": " + kb['treatment'] + " " + DISCLAIMER

            # Default overview
            return kb['definition'] + " " + DISCLAIMER

    # 4b. Topic keyword aliases → send directly to Groq for a natural answer
    GROQ_KEYWORDS = [
        # SKIN / ACNE keywords
        "skin", "skincare", "skin care", "moisturize", "moisturizer", "cleanser",
        "sunscreen", "spf", "exfoliate", "toner", "serum", "routine", "tips",
        "glow", "glowing", "dark spot", "dark circle", "oily", "dry skin",
        "pore", "redness", "rash", "itchy", "allergy", "dermatologist",
        "vitamin c", "retinol", "face wash", "diet", "hydrate", "water",
        "pimple", "blackhead", "whitehead", "blemish", "breakout", "clogged",
        "sebum", "comedone", "bumps", "facial", "complexion", "pigmentation",
        "hyperpigmentation", "scar", "mark", "tan", "sunburn", "face",
        "nose", "chin", "forehead", "cheek", "jaw", "t-zone", "combination skin",
        "sensitive skin", "normal skin", "fair skin", "dusky", "makeup", "primer",
        "foundation", "concealer", "spf", "talc", "niacinamide", "hyaluronic acid",
        "glycolic acid", "salicylic acid", "benzoyl peroxide", "aloe vera",
        "tea tree", "charcoal", "clay mask", "sheet mask", "overnight", "night cream",
        "eye cream", "neck", "lip", "chapped lips", "cracked skin",

        # WOUND keywords
        "cut", "bleed", "bandage", "antiseptic", "infection", "wound",
        "scratch", "scrape", "bruise", "swelling", "stitches", "suture",
        "laceration", "puncture", "tetanus", "antibiotic", "pus", "discharge",
        "gauze", "dressing", "first aid", "emergency", "healing", "tissue",
        "scab", "clot", "blood", "deep cut", "injury",
        "bite", "animal bite", "burn", "blister", "abrasion", "pressure sore",
        "ulcer", "diabetic wound", "chronic wound", "keloid", "scar tissue",
        "inflammation", "swollen", "warm skin", "fever after injury", "pain",

        # MELANOMA / SKIN CANCER keywords
        "mole", "lesion", "tumor", "cancer", "abcde", "uv", "ultraviolet",
        "sunblock", "biopsy", "stage", "malignant", "benign", "dermatoscopy",
        "spread", "metastasis", "lymph", "suspicious", "changing", "asymmetry",
        "border", "irregular", "color change", "diameter", "evolving",
        "skin check", "self exam", "dermatology", "oncology", "excision", "dark mole",
        "new mole", "flat spot", "raised", "itchy mole", "bleeding mole",
        "skin cancer", "basal cell", "squamous", "carcinoma", "actinic", "keratosis",
        "nevi", "nevus", "phototherapy", "dysplastic", "sentinel", "dermoscopy",
        "growth", "nodule", "plaque", "patch", "papule", "pustule",

        # GENERAL HEALTH / LIFESTYLE keywords
        "health", "healthy", "prevent", "prevention", "protect", "protection",
        "food", "eat", "diet", "nutrition", "vitamin", "supplement", "mineral",
        "water", "sleep", "stress", "exercise", "yoga", "gym", "fitness",
        "doctor", "consult", "hospital", "clinic", "treatment", "medicine",
        "cream", "lotion", "gel", "ointment", "spray", "tablet", "pill",
        "natural", "home remedy", "organic", "ayurvedic", "herbal",
        "how to", "what is", "why does", "when should", "can i", "should i",
        "is it safe", "is it normal", "what causes", "how long", "how often",
        "best way", "good for", "bad for", "avoid", "recommend", "suggest",
        "age", "aging", "wrinkle", "fine line", "collagen", "elastin",
        "hair", "hair loss", "dandruff", "scalp", "nail", "brittle nail",
        "fungal", "fungus", "bacterial", "viral", "contagious", "spread",
        "humid", "weather", "climate", "cold", "hot", "sweat", "perspire"
    ]
    if any(kw in q for kw in GROQ_KEYWORDS):
        # Go directly to Groq for these conversational skin/wound topics
        history = []
        try:
            db_msgs = list(ChatHistory.objects(userId=user_id).order_by('-timestamp')[:7])
            for msg in reversed(db_msgs):
                role = "user" if msg.sender == "user" else "assistant"
                history.append({"role": role, "content": msg.message})
        except:
            pass
        ai_answer = get_ai_response(question, history)
        if ai_answer:
            return ai_answer

    # 5. Groq AI Fallback for ANY other question (skin tips, general questions etc.)
    history = []
    try:
        db_msgs = list(ChatHistory.objects(userId=user_id).order_by('-timestamp')[:7])
        for msg in reversed(db_msgs):
            role = "user" if msg.sender == "user" else "assistant"
            history.append({"role": role, "content": msg.message})
    except:
        pass

    ai_answer = get_ai_response(question, history)
    if ai_answer:
        return ai_answer

    # 6. Final fallback
    return ("I can help with skin tips, acne, melanoma, wounds, and more. "
            "Try asking: 'What are skin care tips?' or 'How to prevent acne?' "
            "or tap one of the suggestions below!")


# ----- ROUTES -----

@chatbot_bp.route("/chatbot", methods=["POST"])
def chatbot():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"answer": "No data received"}), 400

        question = data.get("question", "")
        user_id = str(data.get("userId", "guest"))

        print(f"--- Chatbot: [{user_id}] asked: '{question}' ---")

        # Save user message
        try:
            ChatHistory(userId=user_id, message=question, sender='user').save()
        except:
            pass

        # Get answer
        answer = get_expert_response(question, user_id)

        # Save bot answer
        try:
            ChatHistory(userId=user_id, message=answer, sender='bot').save()
        except:
            pass

        # Clean up old messages - keep only last 20
        cleanup_old_history(user_id)

        return jsonify({"answer": answer})

    except Exception as e:
        print(f"CRITICAL CHATBOT ERROR: {e}")
        return jsonify({"answer": "Sorry, something went wrong. Please try again!"})


@chatbot_bp.route("/chatbot/history/<userId>", methods=["GET"])
def get_chat_history(userId):
    try:
        # Only return last 10 messages to the app
        messages = ChatHistory.objects(userId=str(userId)).order_by('-timestamp')[:10]
        return jsonify([msg.to_dict() for msg in reversed(list(messages))])
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@chatbot_bp.route("/chatbot/suggestions", methods=["GET"])
def get_suggestions():
    """Returns top questions based on category"""
    category = request.args.get('category', '').lower()
    suggestions = []

    if category in MEDICAL_KNOWLEDGE:
        for faq in MEDICAL_KNOWLEDGE[category]['faq'][:7]:
            suggestions.append(faq['q'])
    else:
        for key in MEDICAL_KNOWLEDGE:
            for faq in MEDICAL_KNOWLEDGE[key]['faq'][:2]:
                suggestions.append(faq['q'])

    suggestions.insert(0, "What are my latest scan results?")
    return jsonify({"suggestions": suggestions[:10]})

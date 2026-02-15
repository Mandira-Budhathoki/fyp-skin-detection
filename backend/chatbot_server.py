from flask import Blueprint, request, jsonify
from transformers import pipeline, BioGptTokenizer, BioGptForCausalLM
import os

# Create Blueprint
chatbot_bp = Blueprint('chatbot_bp', __name__)

MODEL_NAME = "microsoft/biogpt"

# ----- SCOPE FOR RULE-BASED CHECK -----
SCOPE_KEYWORDS = ["skin", "melanoma", "wound", "lesion", "rash", "scar", "burn"]

# ----- LOAD MODEL -----
print("Loading BioGPT model (this may take a minute on CPU)...")
model = BioGptForCausalLM.from_pretrained(MODEL_NAME)
tokenizer = BioGptTokenizer.from_pretrained(MODEL_NAME)

generator = pipeline("text-generation", model=model, tokenizer=tokenizer)
print("✅ BioGPT model ready!")

# ----- HELPER FUNCTION -----
def is_in_scope(question):
    question_lower = question.lower()
    for keyword in SCOPE_KEYWORDS:
        if keyword in question_lower:
            return True
    return False

def ask_bot(question):
    if not is_in_scope(question):
        return "I can only provide information about skin, wounds, and melanoma. For other issues, consult a professional."
    
    output = generator(
        question,
        max_length=200,
        num_return_sequences=1,
        do_sample=True
    )

    return output[0]["generated_text"]

# ----- ROUTE USING BLUEPRINT -----
@chatbot_bp.route("/chatbot", methods=["POST"])
def chatbot():
    data = request.get_json()
    question = data.get("question", "")

    if question.strip() == "":
        return jsonify({"error": "No question provided"}), 400

    answer = ask_bot(question)
    return jsonify({"answer": answer})

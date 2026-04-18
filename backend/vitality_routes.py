from flask import Blueprint, request, jsonify
from appointment_models import VitalityData, JournalEntry
import mongoengine

vitality_bp = Blueprint('vitality', __name__)

@vitality_bp.route('/api/vitality/analyze', methods=['POST'])
def analyze_vitality():
    try:
        data = request.json
        user_id = data.get('userId')
        height = float(data.get('height', 0))
        weight = float(data.get('weight', 0))
        steps = int(data.get('steps', 0))
        sleep_hours = float(data.get('sleepHours', 0))
        water_intake = float(data.get('waterIntake', 0))
        sun_exposure = float(data.get('sunExposure', 2.0)) # in hours

        if not user_id:
            return jsonify({"error": "userId is required"}), 400

        # Calculate BMI
        bmi = 0
        bmi_category = "Unknown"
        bmi_advice = ""
        if height > 0 and weight > 0:
            height_m = height / 100
            bmi = weight / (height_m * height_m)
            if bmi < 18.5:
                bmi_category = "Underweight"
                bmi_advice = "Focus on nutrient-dense foods to reach a healthy weight."
            elif 18.5 <= bmi < 24.9:
                bmi_category = "Normal"
                bmi_advice = "Great! Maintain your balanced lifestyle."
            elif 25 <= bmi < 29.9:
                bmi_category = "Overweight"
                bmi_advice = "Consider a more active lifestyle and portion control."
            else:
                bmi_category = "Obese"
                bmi_advice = "Consult a health professional for personalized guidance."

        # Analysis logic
        sleep_analysis = "Optimal" if sleep_hours >= 7 else "Improvement Needed"
        water_analysis = "Optimal" if water_intake >= 2.5 else "Low Hydration"
        
        vitality_score = 0
        if bmi_category == "Normal": vitality_score += 25
        if sleep_hours >= 7: vitality_score += 25
        if water_intake >= 2.5: vitality_score += 25
        if sun_exposure <= 2.0: vitality_score += 25
        elif sun_exposure <= 4.0: vitality_score += 15

        from datetime import datetime
        custom_date = data.get('date')
        ts = datetime.fromisoformat(custom_date.replace('Z', '+00:00')) if custom_date else datetime.utcnow()

        # Save to DB
        vitality_record = VitalityData(
            userId=user_id,
            height=height,
            weight=weight,
            steps=steps,
            sleepHours=sleep_hours,
            waterIntake=water_intake,
            sunExposure=sun_exposure,
            timestamp=ts
        )
        vitality_record.save()

        return jsonify({
            "status": "success",
            "bmi": round(bmi, 2),
            "bmiCategory": bmi_category,
            "bmiAdvice": bmi_advice,
            "sleepAnalysis": sleep_analysis,
            "waterAnalysis": water_analysis,
            "vitalityScore": vitality_score,
            "insights": [
                f"Your BMI is {round(bmi, 1)}. {bmi_advice}",
                f"Sleep focus: {sleep_analysis} (Target 7-8 hrs)",
                f"Hydration: {water_analysis} (Target 2.5L+)"
            ]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@vitality_bp.route('/api/vitality/history/<user_id>', methods=['GET'])
def get_vitality_history(user_id):
    try:
        from datetime import datetime, timedelta
        # Get data from the last 7 days
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        records = VitalityData.objects(userId=user_id, timestamp__gte=seven_days_ago).order_by('timestamp')
        return jsonify([r.to_dict() for r in records])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@vitality_bp.route('/api/journal', methods=['POST'])
def add_journal_entry():
    try:
        data = request.json
        user_id = data.get('userId')
        content = data.get('content')
        mood = data.get('mood', 'neutral')

        if not user_id or not content:
            return jsonify({"error": "userId and content are required"}), 400

        entry = JournalEntry(userId=user_id, content=content, mood=mood)
        entry.save()

        return jsonify({"status": "success", "entry": entry.to_dict()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@vitality_bp.route('/api/journal/<user_id>', methods=['GET'])
def get_journal_entries(user_id):
    try:
        entries = JournalEntry.objects(userId=user_id)
        return jsonify([e.to_dict() for e in entries])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@vitality_bp.route('/api/journal/entry/<entry_id>', methods=['PUT', 'DELETE'])
def manage_journal_entry(entry_id):
    try:
        from mongoengine import ValidationError
        if request.method == 'DELETE':
            entry = JournalEntry.objects(id=entry_id).first()
            if not entry:
                return jsonify({"error": "Entry not found"}), 404
            entry.delete()
            return jsonify({"status": "success"})
        
        elif request.method == 'PUT':
            data = request.get_json()
            entry = JournalEntry.objects(id=entry_id).first()
            if not entry:
                return jsonify({"error": "Entry not found"}), 404
            
            entry.content = data.get('content', entry.content)
            entry.mood = data.get('mood', entry.mood)
            entry.save()
            return jsonify({"status": "success", "entry": entry.to_dict()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

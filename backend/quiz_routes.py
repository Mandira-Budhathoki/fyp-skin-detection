from flask import Blueprint, request, jsonify
from appointment_models import clean_data
import mongoengine
from datetime import datetime

quiz_bp = Blueprint('quiz_bp', __name__)

class QuizQuestion(mongoengine.DynamicDocument):
    category = mongoengine.StringField(required=True)
    question = mongoengine.StringField(required=True)
    options = mongoengine.ListField(mongoengine.StringField(), required=True)
    correctIndex = mongoengine.IntField(required=True)
    explanation = mongoengine.StringField()
    createdAt = mongoengine.DateTimeField(default=datetime.utcnow)

    meta = {'collection': 'quiz_questions', 'ordering': ['-createdAt']}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            'category': self.category,
            'question': self.question,
            'options': self.options,
            'correctIndex': self.correctIndex,
            'explanation': self.explanation,
            'createdAt': self.createdAt
        })

class QuizResult(mongoengine.DynamicDocument):
    userId = mongoengine.StringField(required=True)
    category = mongoengine.StringField(required=True)
    score = mongoengine.IntField(required=True)
    total = mongoengine.IntField(required=True)
    percentage = mongoengine.IntField(required=True)
    timestamp = mongoengine.DateTimeField(default=datetime.utcnow)

    meta = {'collection': 'quiz_results', 'ordering': ['-timestamp']}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            'userId': self.userId,
            'category': self.category,
            'score': self.score,
            'total': self.total,
            'percentage': self.percentage,
            'timestamp': self.timestamp
        })

@quiz_bp.route('/quiz/results', methods=['POST'])
def save_quiz_result():
    try:
        data = request.json
        res = QuizResult(
            userId=data['userId'],
            category=data['category'],
            score=data['score'],
            total=data['total'],
            percentage=data['percentage']
        )
        res.save()
        return jsonify({'success': True, 'result': res.to_dict()}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@quiz_bp.route('/quiz/results/<uid>', methods=['GET'])
def get_user_results(uid):
    results = QuizResult.objects(userId=uid)
    return jsonify([r.to_dict() for r in results]), 200

@quiz_bp.route('/quiz/questions', methods=['GET'])
def get_questions():
    category = request.args.get('category')
    if category:
        questions = QuizQuestion.objects(category=category)
    else:
        questions = QuizQuestion.objects.all()
    return jsonify([q.to_dict() for q in questions]), 200

@quiz_bp.route('/quiz/questions', methods=['POST'])
def add_question():
    try:
        data = request.json
        new_q = QuizQuestion(
            category=data['category'],
            question=data['question'],
            options=data['options'],
            correctIndex=data['correctIndex'],
            explanation=data.get('explanation', '')
        )
        new_q.save()
        return jsonify({'success': True, 'message': 'Question added', 'question': new_q.to_dict()}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@quiz_bp.route('/quiz/questions/<qid>', methods=['DELETE'])
def delete_question(qid):
    try:
        q = QuizQuestion.objects(id=qid).first()
        if not q: return jsonify({'success': False, 'message': 'Not found'}), 404
        q.delete()
        return jsonify({'success': True, 'message': 'Deleted'}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

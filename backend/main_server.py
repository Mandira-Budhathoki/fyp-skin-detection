from flask import Flask
from flask_cors import CORS

# Import Image Analysis Routes
from app import image_bp

# Import Chatbot Routes
from chatbot_server import chatbot_bp


app = Flask(__name__)
CORS(app)

# Register both APIs
app.register_blueprint(image_bp)
app.register_blueprint(chatbot_bp)


@app.route('/')
def home():
    return "Main Flask Server Running Successfully!"


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=3000, debug=True)

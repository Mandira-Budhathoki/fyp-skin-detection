from flask import Flask
from flask_cors import CORS
import os
import sys
from dotenv import load_dotenv
import mongoengine

# Load .env file
load_dotenv()

# Ensure the current directory is in sys.path for local imports
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

# Import Blueprints
from app import image_bp
from chatbot_server import chatbot_bp
from appointment_routes import appointment_bp

app = Flask(__name__)
CORS(app)
app.url_map.strict_slashes = False # Handles trailing slashes gracefully

# Database Config
mongoengine.connect(host=os.getenv('MONGO_URI'))

# Register Blueprints
app.register_blueprint(image_bp, url_prefix='/api') 
app.register_blueprint(chatbot_bp, url_prefix='/api')
app.register_blueprint(appointment_bp, url_prefix='/api/appointments')


@app.route('/')
def home():
    return "Main Flask Server Running Successfully!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=3000, debug=True)



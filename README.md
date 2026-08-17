# 🩺 DermaAI — AI-Powered Skin Health Diagnostic System

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54"/>
  <img src="https://img.shields.io/badge/Node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white"/>
  <img src="https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white"/>
  <img src="https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white"/>
</p>

> **Final Year Project | BSc Computing — Islington College (London Metropolitan University)**

---

## 📌 Project Overview

**DermaAI** is a comprehensive, AI-powered clinical skin diagnostic system. It features a premium cross-platform **Flutter mobile application** backed by a **microservices architecture** combining Node.js and Python (Flask) services.

The system allows users to:
- 🔬 **Detect skin conditions** including Melanoma, Acne, and Eczema using deep learning models trained on medical datasets (ISIC).
- 🧴 **Assess facial health** through multimodal AI analysis combining image and clinical data.
- 🤖 **Interact with an AI chatbot** for personalized skin health advice.
- 📅 **Book appointments** with dermatologists directly through the app.

---

## 🏗️ System Architecture

The system is split into three independent microservices coordinated via an API Gateway:

| Service | Technology | Responsibility |
|---|---|---|
| **Auth Service** | Node.js / Express | User registration, JWT authentication, appointment booking |
| **AI Diagnostic Engine** | Python / Flask + TensorFlow | Deep learning image analysis (Melanoma, Acne, Eczema) |
| **API Gateway** | Node.js | Routes requests to the correct service, exposes via Ngrok |
| **Mobile App** | Flutter / Dart | Cross-platform frontend with premium UI/UX |
| **Database** | MongoDB | Stores user profiles, appointments, and health history |

---

## 🛠️ Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: Node.js, Express.js, Python, Flask
- **AI / ML**: TensorFlow, Keras, HuggingFace Transformers
- **Database**: MongoDB
- **Deployment**: Ngrok (local tunneling)

---

## ⚙️ How to Run the Project

### Prerequisites
Make sure you have the following installed:
- **Node.js** (v18+)
- **Python** (v3.10+)
- **Flutter SDK**
- **MongoDB** (running locally on Port 27017)
- **Ngrok**

---

### Phase 1: Start the Backend

A single automated startup script launches all backend services simultaneously.

```bash
cd backend
.\START_HERE.bat
```

This script automatically:
1. Starts the **Node.js Auth Server** on Port `5000`
2. Activates the Python virtual environment and starts the **AI Server** on Port `3000`
3. Starts the **API Gateway** on Port `8000`
4. Launches an **Ngrok Tunnel** on Port `8000`

> ⚠️ **Important:** Once running, copy the `Forwarding` URL from the Ngrok window (e.g., `https://xyz-123.ngrok-free.app`). You will need it in the next step.

---

### Phase 2: Connect the Mobile App

1. Navigate to `skin_app/lib/services/api_service.dart`
2. Update the `baseUrl` with your Ngrok URL:

```dart
class ApiService {
  static const String baseUrl = "https://your-ngrok-url.ngrok-free.app";
}
```

3. Run the Flutter app:

```bash
flutter clean
flutter pub get
flutter run
```

---

### Phase 3: Run Automated Tests

```bash
cd backend
python test_everything_auto.py
```

This script simulates a full user registration, login, token validation, and AI image upload to verify all services are working correctly.

---

## 📁 Project Structure

```
fyp/
├── backend/
│   ├── server.js              # Node.js Auth & Appointment Service
│   ├── gateway.js             # API Gateway / Proxy
│   ├── main_server.py         # Python Flask AI Diagnostic Engine
│   ├── ai_models/             # TensorFlow model files
│   ├── controllers/           # Route controllers
│   └── START_HERE.bat         # Automated startup script
├── skin_app/
│   ├── lib/
│   │   ├── screens/           # UI screens (Home, Scanner, Chatbot, Booking)
│   │   ├── services/          # HTTP service layer
│   │   └── widgets/           # Reusable custom UI components
└── README.md
```

---

## 👩‍💻 Author

**Mandira Budhathoki**
📧 [mandirabudhathoki091@gmail.com](mailto:mandirabudhathoki091@gmail.com)
🔗 [LinkedIn](https://www.linkedin.com/in/mandira-budhathoki-8077a0338/)
🐙 [GitHub](https://github.com/Mandira-Budhathoki)

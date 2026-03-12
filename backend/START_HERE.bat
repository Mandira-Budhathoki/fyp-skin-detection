@echo off
title FYP Full System Runner (PRO GATEWAY)
echo ======================================================
echo Starting FYP Backend (Auth + AI + Appointments)
echo ======================================================

:: 1. Start Node.js Auth Server (Port 5000)
echo [1/5] Starting Node.js Auth Server on Port 5000...
start "Node.js Auth" cmd /k "cd c:\fyp\backend && npm start"

:: 2. Start Python Service Server (Port 3000)
echo [2/5] Starting Python Service Server on Port 3000...
start "Python Service" cmd /k "cd c:\fyp\backend && venv\Scripts\activate && pip install -r requirements.txt && python main_server.py"

:: 3. Start the Gateway Proxy (Port 8000)
echo [3/5] Starting Gateway Proxy on Port 8000...
timeout /t 3
start "FYP Gateway" cmd /k "cd c:\fyp\backend && node gateway.js"

echo.
echo Waiting for servers to initialize...
timeout /t 5
echo.

echo ======================================================
echo EXPOSING GATEWAY TO THE INTERNET (Ngrok)
echo ======================================================

:: 4. Start ONE Tunnel for the Gateway (Port 8000)
echo [4/5] Starting Ngrok Tunnel...
start "Ngrok Tunnel" cmd /k ".\ngrok http 8000"

echo.
echo ======================================================
echo SYSTEM STARTED SUCCESSFULLY!
echo ------------------------------------------------------
echo 1. Check the "Ngrok Tunnel" window for the URL.
echo 2. Paste this SINGLE URL into 'api_service.dart' in Flutter.
echo ======================================================
pause

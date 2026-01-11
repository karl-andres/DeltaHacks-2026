# FleetGuard - Driver Fitness Monitoring System


**DeltaHacks 2026 Hackathon Project**


FleetGuard is a comprehensive safety platform designed to monitor driver fitness in real-time. It uses physiological markers (Pulse, Breathing Rate) to compute advanced safety metrics and determine if a driver is "FIT" or "UNFIT" to drive.


The system consists of a mobile scanning app, a powerful backend for analysis, and a strategic dashboard for fleet managers.


## 🎥 Demo

[![FleetGuard Demo](https://img.youtube.com/vi/BrNaiGfPUYo/0.jpg)](https://www.youtube.com/watch?v=BrNaiGfPUYo)

## 🚀 Key Features


*   **Real-time Fitness Detection**: Analyzes physiological signals to detect drowsiness, stress, and health risks.
*   **Strategic Fleet Dashboard**: High-level overview of fleet health, critical alerts, and unfit driver counts.
*   **Deep Analytical Insights**: Detailed individual driver pages with trends for Pulse, Breathing, Cardio-Respiratory Coupling (CRC), and Alertness (NAI).
*   **Strict Safety Bounds**: "Kill switch" logic for critical vital signs ensuring immediate identification of unsafe drivers.


## 🛠️ Tech Stack


### Frontend (Dashboard)
*   **Framework**: React with TypeScript
*   **Styling**: TailwindCSS, Shadcn/UI
*   **Visualization**: Recharts for time-series data
*   **Animations**: Framer Motion


### Backend (API & Analysis)
*   **Language**: Python 3.x
*   **Framework**: FastAPI
*   **Database**: PostgreSQL / SQLAlchemy
*   **Notifications**: Twilio SMS API
*   **Logic**: Custom algorithms for vital score integration (IVS) and alertness (NAI).


### Mobile (Scanner)
*   **Codebase**: Swift (iOS)
*   **Function**: Captures raw physiological data and sends it to the backend for scoring.


---


## 🏗️ Setup Instructions


### Prerequisites
*   Node.js (v18+)
*   Python (v3.9+)
*   PostgreSQL (or SQLite for local dev)


### 1. Backend Setup
Navigate to the `backend` directory:
```bash
cd backend
```


Create and activate a virtual environment:
```bash
# Windows
python -m venv .venv
.venv\Scripts\activate


# Mac/Linux
python3 -m venv .venv
source .venv/bin/activate
```


Install dependencies:
```bash
pip install -r requirements.txt
```


```


Run the server:
```bash
python main.py
# Server runs at http://localhost:8000
```


### 2. Frontend Setup
Navigate to the `frontend` directory:
```bash
cd frontend
```


Install dependencies:
```bash
npm install
```


Run the development server:
```bash
npm run dev
# Dashboard runs at http://localhost:5173
```


---


## 🧠 The Algorithm


FleetGuard uses a strict, multi-factor scoring system to ensure safety. A driver is marked **UNFIT** if their Risk Score is `5` or higher.


**Risk Factors:**
*   **Safety Bounds (+10)**: Immediate fail if Pulse < 50 or > 120, or Breathing < 8 or > 35.
*   **Drowsiness (+2-3)**: Low PRQ (Pulse-Respiration Quotient) or Low NAI (Nonlinear Alertness Index).
*   **Stress (+2)**: High CRC (Cardio-Respiratory Coupling).


This system ensures that while one minor anomaly might be a warning, any combination of risk factors or a critical vital sign failure results in an immediate "UNFIT" status and an SMS alert to the manager.


---


## 📱 API Endpoints


*   `POST /detect`: Receives raw scan data, computes scores, saves to DB, and sends alerts if unfit.
*   `GET /home`: Returns fleet-level statistics (Fit vs Unfit, Critical Alerts).
*   `GET /drivers/:name`: Returns detailed scan history and metrics for a specific driver.


---
*Built with ❤️ for DeltaHacks 2026*

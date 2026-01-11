from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
from datetime import datetime
from detection import detection
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import func
from db import get_db, Scan

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all origins, change to ["http://localhost:3000"] in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Metric(BaseModel):
    time: float
    value: float


class ScanInput(BaseModel):
    driver_id: str
    fullname: str
    timestamp: datetime
    pulse_rate: List[Metric]
    breathing_rate: List[Metric]
    landmarks_stable: bool


@app.get("/")
def home():
    return {"running": True}

@app.get("/home")
def dashboard_metrics(db: Session = Depends(get_db)):
    """
    Returns dashboard metrics aggregated from the scans table.
    """
    # 1. Avg Fleet Readiness (avg IVS)
    avg_ivs = db.query(func.avg(Scan.integrated_vital_score)).scalar() or 0.0

    # 2. Critical Alert Count (Drivers with NAI < 8.0, matching detection.py threshold)
    # Note: image said 0.6, but code uses different scale. Using 8.0 as 'Low Alertness' threshold.
    critical_count = db.query(Scan).filter(Scan.nonlinear_alertness_index < 8.0).count()

    # 3. Cardio-Sync Status (Avg CRC healthy range)
    avg_crc = db.query(func.avg(Scan.cardio_respiratory_coupler)).scalar() or 0.0
    is_synced = avg_crc < 20.0 # Healthy if under 20

    # 4. Vitality Baseline (Pulse Delta)
    # Using simple average pulse vs standard baseline (e.g. 70 bpm)
    avg_pulse = db.query(func.avg(Scan.pulse_rate)).scalar() or 0.0
    stress_delta = avg_pulse - 70.0

    return {
        "avgFleetReadiness": round(avg_ivs, 2),
        "criticalAlertCount": critical_count,
        "isSystemSynced": is_synced,
        "fleetStressDelta": round(stress_delta, 2),
        "raw_aggregates": {
            "avg_pulse": round(avg_pulse, 1),
            "avg_crc": round(avg_crc, 1)
        }
    }

@app.get("/drivers/{fullname}")
def get_driver_scans(fullname: str, db: Session = Depends(get_db)):
    """
    Returns all scans for a specific driver by full name.
    Limits to the last 100 records for performance.
    """
    scans = db.query(Scan).filter(Scan.fullname == fullname)\
              .order_by(Scan.timestamp.desc())\
              .limit(100)\
              .all()
    return scans

@app.post("/detect")
def detect_scan(data: ScanInput):
    print(data.model_dump_json(indent=2))
    x = detection(data)
    return {"status": x}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

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
    allow_origins=["*"],
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
    Returns fleet-level dashboard metrics.
    This is a strategic overview for fleet managers - no individual biometrics.
    """
    from sqlalchemy import distinct
    
    # Total scans count
    total_scans = db.query(Scan).count()
    
    # Unique drivers count
    unique_drivers = db.query(distinct(Scan.fullname)).count()
    
    # Status distribution (count of PASS vs FAIL scans)
    pass_count = db.query(Scan).filter(Scan.status == "PASS").count()
    fail_count = db.query(Scan).filter(Scan.status == "FAIL").count()
    
    # Drivers with critical alerts (at least one scan with NAI < 8.0)
    critical_scans = db.query(Scan).filter(Scan.nonlinear_alertness_index < 8.0).count()
    
    # Get unique drivers and calculate their fitness status
    driver_names = db.query(distinct(Scan.fullname)).all()
    
    fit_drivers = 0
    unfit_drivers = 0
    drivers_requiring_attention = []
    
    for (fullname,) in driver_names:
        # Get latest scan for this driver
        latest = db.query(Scan).filter(Scan.fullname == fullname)\
                   .order_by(Scan.timestamp.desc()).first()
        
        if latest:
            # Calculate average risk for this driver
            avg_risk = db.query(func.avg(Scan.risk_score))\
                        .filter(Scan.fullname == fullname).scalar() or 0
            
            if avg_risk < 5:
                fit_drivers += 1
            else:
                unfit_drivers += 1
                # Add to attention list
                drivers_requiring_attention.append({
                    "fullname": fullname,
                    "latestStatus": latest.status,
                    "avgRiskScore": round(avg_risk, 1),
                    "lastScanTime": latest.timestamp.isoformat() if latest.timestamp else None
                })
    
    # Sort attention list by risk (highest first) and limit to top 5
    drivers_requiring_attention.sort(key=lambda x: x["avgRiskScore"], reverse=True)
    drivers_requiring_attention = drivers_requiring_attention[:5]
    
    return {
        # Fleet counts
        "totalDrivers": unique_drivers,
        "totalScans": total_scans,
        
        # Status distribution
        "fitDrivers": fit_drivers,
        "unfitDrivers": unfit_drivers,
        "passScans": pass_count,
        "failScans": fail_count,
        
        # Alerts
        "criticalAlertCount": critical_scans,
        
        # Fleet health indicator (percentage of fit drivers)
        "fleetHealthPercent": round((fit_drivers / unique_drivers * 100) if unique_drivers > 0 else 0, 1),
        
        # Drivers that need attention (unfit only, top 5)
        "driversRequiringAttention": drivers_requiring_attention
    }

@app.get("/drivers")
def get_all_drivers(db: Session = Depends(get_db)):
    """
    Returns a list of all unique drivers with aggregated statistics.
    Used by the frontend dashboard to display the driver fleet table.
    """
    from sqlalchemy import distinct
    
    # Get all unique driver names
    driver_names = db.query(distinct(Scan.fullname)).all()
    
    drivers = []
    for (fullname,) in driver_names:
        # Get all scans for this driver
        scans = db.query(Scan).filter(Scan.fullname == fullname)\
                  .order_by(Scan.timestamp.desc())\
                  .all()
        
        if not scans:
            continue
            
        # Calculate aggregates
        total_risk = sum(s.risk_score or 0 for s in scans)
        total_ivs = sum(s.integrated_vital_score or 0 for s in scans)
        avg_risk = total_risk / len(scans)
        avg_ivs = total_ivs / len(scans)
        
        latest_scan = scans[0]
        
        drivers.append({
            "fullname": fullname,
            "driver_id": latest_scan.driver_id,
            "scanCount": len(scans),
            "averageRiskScore": round(avg_risk, 2),
            "averageIVS": round(avg_ivs, 2),
            "status": "FIT" if avg_risk < 5 else "UNFIT",
            "latestScan": {
                "id": latest_scan.id,
                "timestamp": latest_scan.timestamp.isoformat() if latest_scan.timestamp else None,
                "status": latest_scan.status,
                "risk_score": latest_scan.risk_score
            }
        })
    
    # Sort by risk score descending
    drivers.sort(key=lambda d: d["averageRiskScore"], reverse=True)
    
    return drivers

@app.get("/drivers/{fullname}")
def get_driver_scans(fullname: str, db: Session = Depends(get_db)):
    """
    Returns all scans for a specific driver by full name.
    """
    scans = db.query(Scan).filter(Scan.fullname == fullname).all()
    return scans

@app.post("/detect")
def detect_scan(data: ScanInput):
    print(data.model_dump_json(indent=2))
    x = detection(data)
    return {"status": x}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

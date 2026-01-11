from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
from detection import detection

app = FastAPI()

class ScanInput(BaseModel):
    driver_id: str
    fullname: str
    timestamp: datetime
    pulse_respiration_quotient: float
    inhale_exhale_ratio: float
    breathing_rate: float
    pulse_rate: float
    amplitude: float
    landmarks_stable: bool

@app.get("/")
def home():
    return {"running": "true"}

@app.post("/detect")
def detect_scan(data: ScanInput):
    print(data.model_dump_json(indent=2))
    return {"status": "true"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

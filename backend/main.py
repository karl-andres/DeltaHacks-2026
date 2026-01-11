from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
from detection import detection
from typing import List
from detection import detection

app = FastAPI()


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

@app.post("/detect")
def detect_scan(data: ScanInput):
    print(data.model_dump_json(indent=2))
    x = detection(data)
    return {"status": x}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

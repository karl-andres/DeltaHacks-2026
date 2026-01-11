from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

class Scan(Base):
    __tablename__ = "scans"

    id = Column(Integer, primary_key=True, index=True)
    driver_id = Column(String, index=True)
    fullname = Column(String)
    timestamp = Column(DateTime)
    pulse_respiration_quotient = Column(Float) # pulseRespirationQuotient
    inhale_exhale_ratio = Column(Float) # inhaleExhaleRatio
    breathing_rate = Column(Float) # Breathing.rate
    pulse_rate = Column(Float) # Pulse.rate
    amplitude = Column(Float) # Amplitude
    landmarks_stable = Column(Boolean) # Landmarks.stable
    status = Column(String)
    risk_score = Column(Float) # riskscore
    fail_reason = Column(String) # failreason

def init_db():
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

if __name__ == "__main__":
    print("Creating database tables...")
    init_db()
    print("Tables created successfully.")
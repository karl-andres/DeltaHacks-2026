import statistics
from db import SessionLocal, Scan

def detection(data):
    """
    Driver fitness detection algorithm.
    1. Calculates average Pulse and Breathing rates from input lists.
    2. Computes derived metrics (PRQ, IVS, CRC, NAI).
    3. Saves detailed stats to the database.
    4. Returns True (FIT) or False (UNFIT) based on risk analysis.
    """
    
    # 1. Parsing & Average Calculation
    if hasattr(data, 'dict'):
        data_dict = data.dict()
    else:
        data_dict = data
    
    try:
        p_raw = data_dict.get('pulse_rate')
        b_raw = data_dict.get('breathing_rate')

        def get_average(raw_data):
            # If list of dicts with 'value' key (Time-Series) -> Calculate Mean
            if isinstance(raw_data, list):
                values = [item['value'] for item in raw_data if isinstance(item, dict) and 'value' in item]
                if not values: return None
                return statistics.mean(values)
            # If scalar -> Return directly
            elif isinstance(raw_data, (int, float)):
                return float(raw_data)
            return None

        pulse_rate = get_average(p_raw)
        breathing_rate = get_average(b_raw)

        if pulse_rate is None or breathing_rate is None:
             print("Error: Missing or invalid vital data.")
             return False

    except Exception as e:
        print(f"Data Extraction Error: {e}")
        return False

    # --- 2. Advanced Metric Calculation ---

    # Pulse-Respiration Quotient (PRQ)
    prq = pulse_rate / breathing_rate if breathing_rate != 0 else 0

    # Integrated Vital Score (IVS)
    ivs = (pulse_rate * breathing_rate) / 100

    # Cardio-Respiratory Coupler (CRC)
    crc = abs(pulse_rate - (4 * breathing_rate))

    # Nonlinear Alertness Index (NAI)
    nai = (pow(prq, 2) * ivs) / (10 + crc)

    # --- 3. Risk Scoring ---
    risk_score = 0
    signals = []

    # A. Safety Bounds
    if pulse_rate < 50 or pulse_rate > 120: 
        risk_score += 10
        signals.append(f"HR Safety ({pulse_rate:.1f})")
    
    if breathing_rate < 8 or breathing_rate > 35: 
        risk_score += 10
        signals.append(f"RR Safety ({breathing_rate:.1f})")

    # B. Drowsiness / Low Arousal
    if prq < 3.2: 
        risk_score += 3
        signals.append(f"Low PRQ ({prq:.2f})")
    
    if ivs < 6.5: 
        risk_score += 3
        signals.append(f"Low IVS ({ivs:.2f})")
    
    if nai < 8.0: 
        risk_score += 2
        signals.append(f"Low NAI ({nai:.2f})")

    # C. Stress / Decoupling
    if crc > 20: 
        risk_score += 2
        signals.append(f"High CRC ({crc:.1f})")
        
    if prq > 5.5: 
        risk_score += 2
        signals.append(f"High PRQ ({prq:.2f})")

    # Determine Verdict
    # Threshold: >= 5 is FAIL (False), otherwise PASS (True)
    is_fit = risk_score < 5
    
    status_str = "PASS" if is_fit else "FAIL"
    fail_reason = "; ".join(signals) if signals else "Hypo-vigilance not detected"

    print(f"[Detection] HR:{pulse_rate:.1f} RR:{breathing_rate:.1f} -> Risk:{risk_score} ({status_str})")

    # --- 4. Database Saving ---
    # --- 4. Database Saving ---
    db = SessionLocal()
    try:
        driver_id = data_dict.get('driver_id', 'unknown')
        fullname = data_dict.get('fullname', 'unknown')
        timestamp = data_dict.get('timestamp')

        new_scan = Scan(
            driver_id=driver_id,
            fullname=fullname,
            timestamp=timestamp,
            
            pulse_rate=pulse_rate,
            breathing_rate=breathing_rate,
            pulse_respiration_quotient=prq,
            integrated_vital_score=ivs,
            cardio_respiratory_coupler=crc,
            nonlinear_alertness_index=nai,
            
            status=status_str,
            risk_score=float(risk_score), 
            fail_reason=fail_reason
        )
        db.add(new_scan)
        db.commit()
        print(f"[Database] Scan saved.")

    except Exception as e:
        print(f"[Database] Save failed: {e}")
        db.rollback()
    finally:
        db.close()

    # --- 5. Return Boolean ---
    return is_fit
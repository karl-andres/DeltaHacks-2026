/**
 * API Types
 * 
 * Types derived from backend API responses.
 * TODO: Adjust field names here if backend response structure changes.
 */

// ============================================
// Home Dashboard Response (/home)
// ============================================

export interface HomeResponse {
    /** Average Integrated Vital Score across fleet */
    avgFleetReadiness: number;
    /** Count of drivers with critical alerts (NAI < 8.0) */
    criticalAlertCount: number;
    /** Whether cardio-respiratory coupling is healthy (CRC < 20) */
    isSystemSynced: boolean;
    /** Fleet pulse delta from 70 bpm baseline */
    fleetStressDelta: number;
    /** Raw aggregate values */
    raw_aggregates: {
        avg_pulse: number;
        avg_crc: number;
    };
}

// ============================================
// Scan Types (/drivers/{fullName})
// ============================================

export interface Scan {
    id: number;
    driver_id: string;
    fullname: string;
    timestamp: string;

    // Core vitals
    pulse_rate: number;
    breathing_rate: number;
    pulse_respiration_quotient: number;

    // Derived metrics
    integrated_vital_score: number;
    cardio_respiratory_coupler: number;
    nonlinear_alertness_index: number;

    // Status
    status: 'PASS' | 'FAIL';
    risk_score: number;
    fail_reason: string | null;
}

export type DriverScans = Scan[];

// ============================================
// Driver Summary (/drivers)
// ============================================

export interface DriverSummary {
    fullname: string;
    driver_id: string;
    scanCount: number;
    averageRiskScore: number;
    averageIVS: number;
    status: 'FIT' | 'UNFIT';
    latestScan: {
        id: number;
        timestamp: string | null;
        status: string;
        risk_score: number;
    } | null;
}

// ============================================
// Computed Stats (client-side)
// ============================================

export interface VitalStats {
    avgPulse: number;
    avgBreathing: number;
    avgPRQ: number;
    avgIVS: number;
    avgCRC: number;
    avgNAI: number;
    avgRiskScore: number;
}

// ============================================
// Risk Tiers
// ============================================

export type RiskTier = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export function getRiskTier(riskScore: number): RiskTier {
    if (riskScore < 3) return 'LOW';
    if (riskScore < 5) return 'MEDIUM';
    if (riskScore < 8) return 'HIGH';
    return 'CRITICAL';
}

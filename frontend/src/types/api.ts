/**
 * API Types
 * 
 * Types derived from backend API responses.
 * Only includes fields that are actually returned by the API.
 */

// ============================================
// Home Dashboard Response (/home)
// Fleet-level strategic overview - no individual biometrics
// ============================================

export interface HomeResponse {
    // Fleet counts
    totalDrivers: number;
    totalScans: number;

    // Status distribution
    fitDrivers: number;
    unfitDrivers: number;
    passScans: number;
    failScans: number;

    // Alerts
    criticalAlertCount: number;

    // Fleet health (percentage of fit drivers)
    fleetHealthPercent: number;

    // Drivers requiring attention (unfit drivers, max 5)
    driversRequiringAttention: AttentionDriver[];
}

export interface AttentionDriver {
    fullname: string;
    latestStatus: string;
    avgRiskScore: number;
    lastScanTime: string | null;
}

// ============================================
// Driver List Response (/drivers)
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
// Individual Driver Scans (/drivers/{fullName})
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
// Computed Stats (client-side from scans)
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

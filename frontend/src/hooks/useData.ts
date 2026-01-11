/**
 * React Query hooks for data fetching
 * All data comes from real API endpoints - no mock data
 */

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api';
import type { HomeResponse, DriverScans, DriverSummary, VitalStats, Scan } from '@/types';

// ============================================
// Query Keys
// ============================================

export const queryKeys = {
    home: ['home'] as const,
    drivers: ['drivers'] as const,
    driver: (fullName: string) => ['driver', fullName] as const,
};

// ============================================
// Hooks
// ============================================

/**
 * Fetch dashboard home metrics
 */
export function useHomeData() {
    return useQuery<HomeResponse>({
        queryKey: queryKeys.home,
        queryFn: api.fetchHomeData,
    });
}

/**
 * Fetch all drivers with aggregate stats
 */
export function useAllDrivers() {
    return useQuery<DriverSummary[]>({
        queryKey: queryKeys.drivers,
        queryFn: api.fetchAllDrivers,
    });
}

/**
 * Fetch scans for a specific driver
 */
export function useDriverData(fullName: string) {
    return useQuery<DriverScans>({
        queryKey: queryKeys.driver(fullName),
        queryFn: () => api.fetchDriverScans(fullName),
        enabled: !!fullName && fullName.trim().length > 0,
    });
}

// ============================================
// Data Transformation Utilities
// All calculations are derived from actual API scan data
// ============================================

/**
 * Compute aggregate stats from driver scans
 * Each field computed here exists in the Scan object from the API
 */
export function computeDriverStats(scans: DriverScans | undefined): VitalStats | null {
    if (!scans || scans.length === 0) return null;

    const sum = scans.reduce(
        (acc, scan) => ({
            pulse: acc.pulse + (scan.pulse_rate || 0),
            breathing: acc.breathing + (scan.breathing_rate || 0),
            prq: acc.prq + (scan.pulse_respiration_quotient || 0),
            ivs: acc.ivs + (scan.integrated_vital_score || 0),
            crc: acc.crc + (scan.cardio_respiratory_coupler || 0),
            nai: acc.nai + (scan.nonlinear_alertness_index || 0),
            risk: acc.risk + (scan.risk_score || 0),
        }),
        { pulse: 0, breathing: 0, prq: 0, ivs: 0, crc: 0, nai: 0, risk: 0 }
    );

    const count = scans.length;

    return {
        avgPulse: sum.pulse / count,
        avgBreathing: sum.breathing / count,
        avgPRQ: sum.prq / count,
        avgIVS: sum.ivs / count,
        avgCRC: sum.crc / count,
        avgNAI: sum.nai / count,
        avgRiskScore: sum.risk / count,
    };
}

// Type for driver summary built from scans (different from API DriverSummary)
export interface ComputedDriverSummary {
    fullname: string;
    driver_id: string;
    latestScan: Scan;
    scanCount: number;
    averageRiskScore: number;
    averageIVS: number;
    status: 'FIT' | 'UNFIT';
}

/**
 * Compute driver summary from individual scans
 * This is used on the driver detail page
 */
export function computeDriverSummary(scans: DriverScans | undefined): ComputedDriverSummary | null {
    if (!scans || scans.length === 0) return null;

    const latestScan = scans[0]; // Scans ordered by timestamp desc from API
    const avgRisk = scans.reduce((sum, s) => sum + (s.risk_score || 0), 0) / scans.length;
    const avgIVS = scans.reduce((sum, s) => sum + (s.integrated_vital_score || 0), 0) / scans.length;

    return {
        fullname: latestScan.fullname,
        driver_id: latestScan.driver_id,
        latestScan,
        scanCount: scans.length,
        averageRiskScore: avgRisk,
        averageIVS: avgIVS,
        status: avgRisk < 5 ? 'FIT' : 'UNFIT',
    };
}

/**
 * API Client Layer
 * 
 * Typed fetch wrapper with:
 * - Base URL configuration via environment variable
 * - Robust error handling
 * - Only real API data - no mock values
 */

import type { HomeResponse, DriverScans, DriverSummary } from '@/types';

// ============================================
// Configuration
// ============================================

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

// ============================================
// Error Classes
// ============================================

export class ApiError extends Error {
    constructor(
        message: string,
        public status?: number,
        public statusText?: string,
        public url?: string
    ) {
        super(message);
        this.name = 'ApiError';
    }
}

export class NetworkError extends Error {
    constructor(message: string = 'Network error - check your connection') {
        super(message);
        this.name = 'NetworkError';
    }
}

// ============================================
// Fetch Wrapper
// ============================================

interface FetchOptions extends RequestInit {
    timeout?: number;
}

async function fetchWithTimeout(
    url: string,
    options: FetchOptions = {}
): Promise<Response> {
    const { timeout = 10000, ...fetchOptions } = options;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
        const response = await fetch(url, {
            ...fetchOptions,
            signal: controller.signal,
        });
        return response;
    } finally {
        clearTimeout(timeoutId);
    }
}

async function apiRequest<T>(
    endpoint: string,
    options: FetchOptions = {}
): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`;

    try {
        const response = await fetchWithTimeout(url, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
            },
            ...options,
        });

        if (!response.ok) {
            throw new ApiError(
                `API error: ${response.status} ${response.statusText}`,
                response.status,
                response.statusText,
                url
            );
        }

        const text = await response.text();
        if (!text || text.trim() === '') {
            return [] as T;
        }

        try {
            return JSON.parse(text) as T;
        } catch {
            throw new ApiError(`Invalid JSON from ${url}`, undefined, undefined, url);
        }
    } catch (error) {
        if (error instanceof Error && error.name === 'AbortError') {
            throw new NetworkError('Request timed out');
        }

        if (error instanceof TypeError && error.message.includes('fetch')) {
            throw new NetworkError('Cannot connect to server');
        }

        if (error instanceof ApiError || error instanceof NetworkError) {
            throw error;
        }

        throw new ApiError(
            error instanceof Error ? error.message : 'Unknown error'
        );
    }
}

// ============================================
// API Endpoints
// ============================================

/**
 * GET /home - Dashboard aggregate metrics
 */
export async function fetchHomeData(): Promise<HomeResponse> {
    return apiRequest<HomeResponse>('/home');
}

/**
 * GET /drivers - List all drivers with aggregate stats
 */
export async function fetchAllDrivers(): Promise<DriverSummary[]> {
    return apiRequest<DriverSummary[]>('/drivers');
}

/**
 * GET /drivers/{fullName} - All scans for a specific driver
 */
export async function fetchDriverScans(fullName: string): Promise<DriverScans> {
    const encodedName = encodeURIComponent(fullName);
    return apiRequest<DriverScans>(`/drivers/${encodedName}`);
}

// ============================================
// Export
// ============================================

export const api = {
    fetchHomeData,
    fetchAllDrivers,
    fetchDriverScans,
};

export default api;

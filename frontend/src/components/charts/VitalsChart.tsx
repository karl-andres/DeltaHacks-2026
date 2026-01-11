/**
 * VitalsChart - Configurable chart for any combination of scan metrics
 * All values plotted are from individual scans (not averages)
 */

import {
    ResponsiveContainer,
    LineChart,
    Line,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    Legend,
} from 'recharts';
import type { Scan } from '@/types';

interface VitalsChartProps {
    scans: Scan[];
    metrics: Array<'pulse' | 'breathing' | 'crc' | 'nai' | 'ivs' | 'prq' | 'risk'>;
    height?: number;
}

const METRIC_CONFIG = {
    pulse: { key: 'pulse_rate', label: 'Pulse (bpm)', color: '#f43f5e' },
    breathing: { key: 'breathing_rate', label: 'Breathing (rpm)', color: '#06b6d4' },
    crc: { key: 'cardio_respiratory_coupler', label: 'CRC', color: '#8b5cf6' },
    nai: { key: 'nonlinear_alertness_index', label: 'NAI', color: '#22c55e' },
    ivs: { key: 'integrated_vital_score', label: 'IVS', color: '#3b82f6' },
    prq: { key: 'pulse_respiration_quotient', label: 'PRQ', color: '#f59e0b' },
    risk: { key: 'risk_score', label: 'Risk', color: '#ef4444' },
};

export function VitalsChart({ scans, metrics, height = 280 }: VitalsChartProps) {
    if (!scans || scans.length === 0) {
        return (
            <div className="flex items-center justify-center h-64 text-muted-foreground text-sm">
                No scan data available
            </div>
        );
    }

    // Transform scans into chart data (chronological order)
    const chartData = [...scans]
        .sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime())
        .map((scan) => {
            const point: Record<string, number | string> = {
                timestamp: new Date(scan.timestamp).toLocaleDateString('en-US', {
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                }),
            };

            // Add each requested metric
            metrics.forEach((metric) => {
                const config = METRIC_CONFIG[metric];
                point[metric] = (scan as Record<string, number>)[config.key] || 0;
            });

            return point;
        });

    return (
        <div style={{ height }}>
            <ResponsiveContainer width="100%" height="100%">
                <LineChart data={chartData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.4} />
                    <XAxis
                        dataKey="timestamp"
                        tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                        tickLine={false}
                        axisLine={{ stroke: 'hsl(var(--border))' }}
                    />
                    <YAxis
                        tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                        tickLine={false}
                        axisLine={false}
                        width={40}
                    />
                    <Tooltip
                        contentStyle={{
                            backgroundColor: 'hsl(var(--card))',
                            border: '1px solid hsl(var(--border))',
                            borderRadius: '8px',
                            fontSize: '12px',
                        }}
                        labelStyle={{ color: 'hsl(var(--foreground))', fontWeight: 600 }}
                        itemStyle={{ color: 'hsl(var(--muted-foreground))' }}
                    />
                    <Legend
                        wrapperStyle={{ fontSize: '12px', paddingTop: '10px' }}
                        iconType="circle"
                        iconSize={8}
                    />
                    {metrics.map((metric) => {
                        const config = METRIC_CONFIG[metric];
                        return (
                            <Line
                                key={metric}
                                type="monotone"
                                dataKey={metric}
                                name={config.label}
                                stroke={config.color}
                                strokeWidth={2}
                                dot={{ fill: config.color, strokeWidth: 0, r: 3 }}
                                activeDot={{ r: 5 }}
                            />
                        );
                    })}
                </LineChart>
            </ResponsiveContainer>
        </div>
    );
}

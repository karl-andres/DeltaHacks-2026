/**
 * CombinedVitalsChart
 * Shows Pulse, CRC, and NAI trends over time
 * Used in the Overview tab for a quick glance at key vitals
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

interface CombinedVitalsChartProps {
    scans: Scan[];
    height?: number;
}

export function CombinedVitalsChart({ scans, height = 280 }: CombinedVitalsChartProps) {
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
        .map((scan) => ({
            timestamp: new Date(scan.timestamp).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
            }),
            pulse: scan.pulse_rate,
            crc: scan.cardio_respiratory_coupler,
            nai: scan.nonlinear_alertness_index,
        }));

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
                    <Line
                        type="monotone"
                        dataKey="pulse"
                        name="Pulse (bpm)"
                        stroke="#f43f5e"
                        strokeWidth={2}
                        dot={{ fill: '#f43f5e', strokeWidth: 0, r: 3 }}
                        activeDot={{ r: 5 }}
                    />
                    <Line
                        type="monotone"
                        dataKey="crc"
                        name="CRC"
                        stroke="#8b5cf6"
                        strokeWidth={2}
                        dot={{ fill: '#8b5cf6', strokeWidth: 0, r: 3 }}
                        activeDot={{ r: 5 }}
                    />
                    <Line
                        type="monotone"
                        dataKey="nai"
                        name="NAI"
                        stroke="#22c55e"
                        strokeWidth={2}
                        dot={{ fill: '#22c55e', strokeWidth: 0, r: 3 }}
                        activeDot={{ r: 5 }}
                    />
                </LineChart>
            </ResponsiveContainer>
        </div>
    );
}

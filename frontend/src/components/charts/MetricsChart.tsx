import {
    LineChart,
    Line,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    Legend,
} from 'recharts';
import { Scan } from '@/types';
import { formatDate } from '@/lib/utils';

interface MetricsChartProps {
    scans: Scan[];
    height?: number;
}

export function MetricsChart({ scans, height = 300 }: MetricsChartProps) {
    // Transform and reverse to show chronological order
    const data = [...scans]
        .reverse()
        .slice(-30) // Last 30 entries
        .map((scan) => ({
            date: formatDate(scan.timestamp),
            prq: scan.pulse_respiration_quotient,
            ivs: scan.integrated_vital_score,
            crc: scan.cardio_respiratory_coupler,
            nai: scan.nonlinear_alertness_index,
        }));

    if (data.length === 0) {
        return (
            <div className="flex items-center justify-center h-[300px] text-muted-foreground">
                No metrics data available
            </div>
        );
    }

    return (
        <ResponsiveContainer width="100%" height={height}>
            <LineChart data={data} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis
                    dataKey="date"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                />
                <YAxis
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                />
                <Tooltip
                    contentStyle={{
                        backgroundColor: 'hsl(var(--card))',
                        border: '1px solid hsl(var(--border))',
                        borderRadius: '8px',
                        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    }}
                    labelStyle={{ color: 'hsl(var(--foreground))' }}
                />
                <Legend />
                <Line
                    type="monotone"
                    dataKey="prq"
                    name="PRQ"
                    stroke="#8b5cf6"
                    strokeWidth={2}
                    dot={{ fill: '#8b5cf6', strokeWidth: 0, r: 2 }}
                />
                <Line
                    type="monotone"
                    dataKey="ivs"
                    name="IVS"
                    stroke="#06b6d4"
                    strokeWidth={2}
                    dot={{ fill: '#06b6d4', strokeWidth: 0, r: 2 }}
                />
                <Line
                    type="monotone"
                    dataKey="nai"
                    name="NAI"
                    stroke="#f97316"
                    strokeWidth={2}
                    dot={{ fill: '#f97316', strokeWidth: 0, r: 2 }}
                />
            </LineChart>
        </ResponsiveContainer>
    );
}

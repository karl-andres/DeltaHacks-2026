import {
    AreaChart,
    Area,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
} from 'recharts';
import { Scan } from '@/types';
import { formatDate } from '@/lib/utils';

interface RiskScoreChartProps {
    scans: Scan[];
    height?: number;
}

export function RiskScoreChart({ scans, height = 300 }: RiskScoreChartProps) {
    // Transform and reverse to show chronological order
    const data = [...scans]
        .reverse()
        .slice(-30) // Last 30 entries
        .map((scan) => ({
            date: formatDate(scan.timestamp),
            risk: scan.risk_score,
            ivs: scan.integrated_vital_score,
        }));

    if (data.length === 0) {
        return (
            <div className="flex items-center justify-center h-[300px] text-muted-foreground">
                No risk data available
            </div>
        );
    }

    return (
        <ResponsiveContainer width="100%" height={height}>
            <AreaChart data={data} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
                <defs>
                    <linearGradient id="riskGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#f59e0b" stopOpacity={0.4} />
                        <stop offset="95%" stopColor="#f59e0b" stopOpacity={0} />
                    </linearGradient>
                </defs>
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
                    domain={[0, 15]}
                />
                <Tooltip
                    contentStyle={{
                        backgroundColor: 'hsl(var(--card))',
                        border: '1px solid hsl(var(--border))',
                        borderRadius: '8px',
                        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    }}
                    labelStyle={{ color: 'hsl(var(--foreground))' }}
                    formatter={(value: number) => [value.toFixed(1), 'Risk Score']}
                />
                <Area
                    type="monotone"
                    dataKey="risk"
                    name="Risk Score"
                    stroke="#f59e0b"
                    strokeWidth={2}
                    fill="url(#riskGradient)"
                />
            </AreaChart>
        </ResponsiveContainer>
    );
}

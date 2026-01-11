import { motion } from 'framer-motion';
import { StatusBadge } from '@/components/ui/Badge';
import { Scan } from '@/types';
import { formatDateTime, formatNumber } from '@/lib/utils';

interface ScanHistoryTableProps {
    scans: Scan[];
    compact?: boolean;
}

export function ScanHistoryTable({ scans, compact = false }: ScanHistoryTableProps) {
    if (scans.length === 0) {
        return (
            <div className="rounded-xl border border-border bg-card p-8 text-center">
                <p className="text-muted-foreground">No scan history available</p>
            </div>
        );
    }

    if (compact) {
        // Simplified view for overview preview
        return (
            <div className="space-y-2">
                {scans.map((scan, index) => (
                    <motion.div
                        key={scan.id}
                        initial={{ opacity: 0, x: -8 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ duration: 0.2, delay: index * 0.05 }}
                        className="flex items-center justify-between p-3 rounded-lg bg-muted/30 hover:bg-muted/50 transition-colors"
                    >
                        <div className="flex items-center gap-3">
                            <StatusBadge status={scan.status} />
                            <span className="text-sm text-foreground">
                                {formatDateTime(scan.timestamp)}
                            </span>
                        </div>
                        <div className="flex items-center gap-4 text-sm">
                            <span className="text-muted-foreground">
                                CRC: <span className="text-foreground font-medium">{formatNumber(scan.cardio_respiratory_coupler)}</span>
                            </span>
                            <span className={`font-semibold ${scan.risk_score >= 5 ? 'text-red-500' : 'text-emerald-500'}`}>
                                Risk: {formatNumber(scan.risk_score, 0)}
                            </span>
                        </div>
                    </motion.div>
                ))}
            </div>
        );
    }

    // Full table view
    return (
        <div className="rounded-xl border border-border bg-card overflow-hidden">
            {/* Header */}
            <div className="grid grid-cols-12 gap-4 px-6 py-3 bg-muted/50 text-xs font-medium text-muted-foreground border-b border-border uppercase tracking-wide">
                <div className="col-span-3">Date & Time</div>
                <div className="col-span-2 text-center">Status</div>
                <div className="col-span-2 text-center">Pulse Rate</div>
                <div className="col-span-2 text-center">CRC</div>
                <div className="col-span-1 text-center">Risk</div>
                <div className="col-span-2">Notes</div>
            </div>

            {/* Rows */}
            <div className="divide-y divide-border max-h-[400px] overflow-y-auto">
                {scans.map((scan, index) => (
                    <motion.div
                        key={scan.id}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ duration: 0.2, delay: index * 0.02 }}
                        className="grid grid-cols-12 gap-4 px-6 py-4 items-center hover:bg-accent/30 transition-colors"
                    >
                        {/* Date */}
                        <div className="col-span-3 text-sm text-foreground">
                            {formatDateTime(scan.timestamp)}
                        </div>

                        {/* Status */}
                        <div className="col-span-2 flex justify-center">
                            <StatusBadge status={scan.status} />
                        </div>

                        {/* Pulse Rate */}
                        <div className="col-span-2 text-center">
                            <span className="font-medium text-foreground">
                                {formatNumber(scan.pulse_rate)}
                            </span>
                            <span className="text-muted-foreground text-sm ml-1">bpm</span>
                        </div>

                        {/* CRC */}
                        <div className="col-span-2 text-center">
                            <span className={`font-medium ${scan.cardio_respiratory_coupler >= 20 ? 'text-amber-500' : 'text-foreground'}`}>
                                {formatNumber(scan.cardio_respiratory_coupler)}
                            </span>
                        </div>

                        {/* Risk Score */}
                        <div className="col-span-1 text-center">
                            <span className={`font-semibold ${scan.risk_score >= 5 ? 'text-red-500' : 'text-emerald-500'}`}>
                                {formatNumber(scan.risk_score, 0)}
                            </span>
                        </div>

                        {/* Notes */}
                        <div className="col-span-2 text-sm text-muted-foreground truncate" title={scan.fail_reason || ''}>
                            {scan.fail_reason || '—'}
                        </div>
                    </motion.div>
                ))}
            </div>
        </div>
    );
}

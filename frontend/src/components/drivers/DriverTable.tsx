import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronRight } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { StatusBadge, RiskBadge } from '@/components/ui/Badge';
import { useAllDrivers } from '@/hooks/useData';
import { getRiskTier, DriverSummary } from '@/types';
import { formatNumber, getRelativeTime } from '@/lib/utils';

export function DriverTable() {
    const { data: drivers, isLoading, error } = useAllDrivers();

    if (isLoading) {
        return <DriverTableSkeleton />;
    }

    if (error) {
        return (
            <div className="rounded-xl border border-border bg-card p-8 text-center">
                <p className="text-sm text-muted-foreground">
                    Unable to load driver data. Check backend connection.
                </p>
            </div>
        );
    }

    if (!drivers || drivers.length === 0) {
        return (
            <div className="rounded-xl border border-dashed border-border bg-card/50 p-12 text-center">
                <p className="text-muted-foreground">
                    No driver scans recorded yet.
                </p>
                <p className="text-sm text-muted-foreground/70 mt-1">
                    Drivers will appear here after biometric scans are processed.
                </p>
            </div>
        );
    }

    return (
        <div className="rounded-xl border border-border bg-card overflow-hidden">
            {/* Header */}
            <div className="grid grid-cols-12 gap-4 px-4 lg:px-6 py-3 bg-muted/30 text-xs font-medium text-muted-foreground border-b border-border uppercase tracking-wide">
                <div className="col-span-5 lg:col-span-4">Driver</div>
                <div className="col-span-2 text-center hidden sm:block">Status</div>
                <div className="col-span-3 lg:col-span-2 text-center">Risk</div>
                <div className="col-span-2 text-center hidden lg:block">IVS</div>
                <div className="col-span-4 lg:col-span-2 text-right">Last Scan</div>
            </div>

            {/* Rows */}
            <div className="divide-y divide-border">
                {drivers.map((driver: DriverSummary, index: number) => {
                    const riskTier = getRiskTier(driver.averageRiskScore);

                    return (
                        <motion.div
                            key={driver.fullname}
                            initial={{ opacity: 0, x: -8 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ duration: 0.25, delay: index * 0.03 }}
                        >
                            <Link
                                to={`/drivers/${encodeURIComponent(driver.fullname)}`}
                                className="grid grid-cols-12 gap-4 px-4 lg:px-6 py-4 items-center hover:bg-accent/30 transition-colors group"
                            >
                                {/* Driver Info */}
                                <div className="col-span-5 lg:col-span-4 flex items-center gap-3 min-w-0">
                                    <Avatar name={driver.fullname} size="sm" />
                                    <div className="min-w-0">
                                        <p className="font-medium text-foreground truncate group-hover:text-emerald-500 transition-colors">
                                            {driver.fullname}
                                        </p>
                                        <p className="text-xs text-muted-foreground">
                                            {driver.scanCount} scan{driver.scanCount !== 1 ? 's' : ''}
                                        </p>
                                    </div>
                                </div>

                                {/* Status */}
                                <div className="col-span-2 hidden sm:flex justify-center">
                                    <StatusBadge status={driver.status} />
                                </div>

                                {/* Risk Score */}
                                <div className="col-span-3 lg:col-span-2 flex flex-col items-center gap-1">
                                    <span className={`text-sm font-semibold ${driver.averageRiskScore >= 5 ? 'text-red-500' : 'text-emerald-500'
                                        }`}>
                                        {formatNumber(driver.averageRiskScore)}
                                    </span>
                                    <RiskBadge tier={riskTier} />
                                </div>

                                {/* IVS */}
                                <div className="col-span-2 text-center hidden lg:block">
                                    <span className="text-sm text-foreground">
                                        {formatNumber(driver.averageIVS)}
                                    </span>
                                </div>

                                {/* Last Scan */}
                                <div className="col-span-4 lg:col-span-2 flex items-center justify-end gap-2">
                                    <span className="text-xs text-muted-foreground">
                                        {driver.latestScan?.timestamp
                                            ? getRelativeTime(driver.latestScan.timestamp)
                                            : '—'}
                                    </span>
                                    <ChevronRight className="h-4 w-4 text-muted-foreground/50 group-hover:text-emerald-500 transition-colors" />
                                </div>
                            </Link>
                        </motion.div>
                    );
                })}
            </div>
        </div>
    );
}

function DriverTableSkeleton() {
    return (
        <div className="rounded-xl border border-border bg-card overflow-hidden">
            <div className="grid grid-cols-12 gap-4 px-4 lg:px-6 py-3 bg-muted/30 border-b border-border">
                <div className="col-span-4 skeleton h-3 w-16" />
                <div className="col-span-2 skeleton h-3 w-12 mx-auto hidden sm:block" />
                <div className="col-span-2 skeleton h-3 w-10 mx-auto" />
                <div className="col-span-2 skeleton h-3 w-8 mx-auto hidden lg:block" />
                <div className="col-span-2 skeleton h-3 w-14 ml-auto" />
            </div>
            <div className="divide-y divide-border">
                {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="grid grid-cols-12 gap-4 px-4 lg:px-6 py-4 items-center">
                        <div className="col-span-4 flex items-center gap-3">
                            <div className="skeleton h-8 w-8 rounded-full" />
                            <div className="space-y-1.5">
                                <div className="skeleton h-3.5 w-24" />
                                <div className="skeleton h-2.5 w-16" />
                            </div>
                        </div>
                        <div className="col-span-2 hidden sm:flex justify-center">
                            <div className="skeleton h-5 w-12 rounded-full" />
                        </div>
                        <div className="col-span-2 flex justify-center">
                            <div className="skeleton h-4 w-6" />
                        </div>
                        <div className="col-span-2 hidden lg:flex justify-center">
                            <div className="skeleton h-4 w-10" />
                        </div>
                        <div className="col-span-2 flex justify-end">
                            <div className="skeleton h-3 w-14" />
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}

export function DriverTableSkeltonWrapper() {
    return <DriverTableSkeleton />;
}

import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
    AlertTriangle,
    CheckCircle2,
    ChevronRight,
    RefreshCw,
    Shield,
    Users,
    XCircle,
} from 'lucide-react';
import { PageHeader } from '@/components/layout/PageHeader';
import { ErrorDisplay } from '@/components/ui/EmptyState';
import { Avatar } from '@/components/ui/Avatar';
import { useHomeData, useAllDrivers } from '@/hooks/useData';
import { getRiskTier } from '@/types';
import { getRelativeTime } from '@/lib/utils';

// Animation variants
const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
        opacity: 1,
        transition: { staggerChildren: 0.06 },
    },
};

const itemVariants = {
    hidden: { opacity: 0, y: 12 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.35, ease: 'easeOut' } },
};

export default function HomePage() {
    const {
        data: homeData,
        isLoading: homeLoading,
        error: homeError,
        refetch: refetchHome,
        isFetching: homeFetching
    } = useHomeData();

    const {
        data: allDrivers,
        isLoading: driversLoading,
    } = useAllDrivers();

    if (homeError) {
        return <ErrorDisplay error={homeError as Error} onRetry={() => refetchHome()} />;
    }

    const isLoading = homeLoading || driversLoading;

    return (
        <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-8"
        >
            {/* Header */}
            <motion.div variants={itemVariants}>
                <PageHeader
                    title="Fleet Overview"
                    subtitle="Strategic dashboard for driver fitness monitoring"
                >
                    <button
                        onClick={() => refetchHome()}
                        disabled={homeFetching}
                        className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors disabled:opacity-50"
                    >
                        <RefreshCw className={`h-4 w-4 ${homeFetching ? 'animate-spin' : ''}`} />
                        {homeFetching ? 'Updating...' : 'Refresh'}
                    </button>
                </PageHeader>
            </motion.div>

            {/* Loading State */}
            {isLoading ? (
                <LoadingSkeleton />
            ) : homeData ? (
                <>
                    {/* Primary Metrics Row */}
                    <motion.div variants={itemVariants} className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                        <MetricCard
                            label="Total Drivers"
                            value={homeData.totalDrivers}
                            icon={<Users className="h-5 w-5" />}
                            color="default"
                        />
                        <MetricCard
                            label="Fleet Health"
                            value={`${homeData.fleetHealthPercent}%`}
                            sublabel={`${homeData.fitDrivers} fit · ${homeData.unfitDrivers} unfit`}
                            icon={<Shield className="h-5 w-5" />}
                            color={homeData.fleetHealthPercent >= 80 ? 'success' : homeData.fleetHealthPercent >= 50 ? 'warning' : 'danger'}
                        />
                        <MetricCard
                            label="Critical Alerts"
                            value={homeData.criticalAlertCount}
                            sublabel="Low alertness detected"
                            icon={<AlertTriangle className="h-5 w-5" />}
                            color={homeData.criticalAlertCount === 0 ? 'success' : 'danger'}
                        />
                        <MetricCard
                            label="Total Scans"
                            value={homeData.totalScans}
                            sublabel={`${homeData.passScans} pass · ${homeData.failScans} fail`}
                            icon={<CheckCircle2 className="h-5 w-5" />}
                            color="default"
                        />
                    </motion.div>

                    {/* Status Distribution + Attention List */}
                    <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                        {/* Status Distribution */}
                        <motion.div
                            variants={itemVariants}
                            className="lg:col-span-2 rounded-xl border border-border bg-card p-6"
                        >
                            <h3 className="text-sm font-semibold text-foreground mb-4">Driver Status Distribution</h3>

                            <div className="space-y-4">
                                {/* Visual bar */}
                                <div className="h-3 rounded-full bg-muted overflow-hidden flex">
                                    {homeData.totalDrivers > 0 && (
                                        <>
                                            <div
                                                className="h-full bg-emerald-500 transition-all duration-500"
                                                style={{ width: `${(homeData.fitDrivers / homeData.totalDrivers) * 100}%` }}
                                            />
                                            <div
                                                className="h-full bg-red-500 transition-all duration-500"
                                                style={{ width: `${(homeData.unfitDrivers / homeData.totalDrivers) * 100}%` }}
                                            />
                                        </>
                                    )}
                                </div>

                                {/* Legend */}
                                <div className="flex items-center justify-between text-sm">
                                    <div className="flex items-center gap-2">
                                        <span className="h-3 w-3 rounded-full bg-emerald-500" />
                                        <span className="text-muted-foreground">Fit</span>
                                        <span className="font-semibold text-foreground">{homeData.fitDrivers}</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <span className="h-3 w-3 rounded-full bg-red-500" />
                                        <span className="text-muted-foreground">Unfit</span>
                                        <span className="font-semibold text-foreground">{homeData.unfitDrivers}</span>
                                    </div>
                                </div>

                                {/* Scan results */}
                                <div className="pt-4 border-t border-border">
                                    <p className="text-xs text-muted-foreground uppercase tracking-wide mb-3">Scan Results</p>
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="flex items-center gap-2">
                                            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
                                            <span className="text-sm text-muted-foreground">Passed</span>
                                            <span className="text-sm font-semibold text-foreground ml-auto">{homeData.passScans}</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <XCircle className="h-4 w-4 text-red-500" />
                                            <span className="text-sm text-muted-foreground">Failed</span>
                                            <span className="text-sm font-semibold text-foreground ml-auto">{homeData.failScans}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </motion.div>

                        {/* Drivers Requiring Attention */}
                        <motion.div
                            variants={itemVariants}
                            className="lg:col-span-3 rounded-xl border border-border bg-card p-6"
                        >
                            <div className="flex items-center justify-between mb-4">
                                <h3 className="text-sm font-semibold text-foreground">Drivers Requiring Attention</h3>
                                {homeData.driversRequiringAttention.length > 0 && (
                                    <span className="text-xs text-red-500 bg-red-500/10 px-2 py-0.5 rounded-full">
                                        {homeData.driversRequiringAttention.length} unfit
                                    </span>
                                )}
                            </div>

                            {homeData.driversRequiringAttention.length === 0 ? (
                                <div className="text-center py-8">
                                    <CheckCircle2 className="h-10 w-10 text-emerald-500/50 mx-auto mb-3" />
                                    <p className="text-sm text-muted-foreground">All drivers are operating within safe parameters.</p>
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    {homeData.driversRequiringAttention.map((driver) => (
                                        <Link
                                            key={driver.fullname}
                                            to={`/drivers/${encodeURIComponent(driver.fullname)}`}
                                            className="flex items-center gap-3 p-3 rounded-lg hover:bg-accent/50 transition-colors group"
                                        >
                                            <Avatar name={driver.fullname} size="sm" />
                                            <div className="flex-1 min-w-0">
                                                <p className="text-sm font-medium text-foreground truncate group-hover:text-emerald-500 transition-colors">
                                                    {driver.fullname}
                                                </p>
                                                <p className="text-xs text-muted-foreground">
                                                    {driver.lastScanTime ? getRelativeTime(driver.lastScanTime) : 'No recent scan'}
                                                </p>
                                            </div>
                                            <div className="text-right">
                                                <span className={`text-sm font-semibold ${driver.avgRiskScore >= 8 ? 'text-red-500' : 'text-amber-500'
                                                    }`}>
                                                    Risk: {driver.avgRiskScore}
                                                </span>
                                            </div>
                                            <ChevronRight className="h-4 w-4 text-muted-foreground/50 group-hover:text-emerald-500 transition-colors" />
                                        </Link>
                                    ))}
                                </div>
                            )}
                        </motion.div>
                    </div>

                    {/* All Drivers List */}
                    <motion.div variants={itemVariants}>
                        <div className="flex items-center justify-between mb-4">
                            <div>
                                <h2 className="text-lg font-semibold text-foreground">All Drivers</h2>
                                <p className="text-sm text-muted-foreground">
                                    Click to view detailed scan history and metrics
                                </p>
                            </div>
                        </div>

                        {!allDrivers || allDrivers.length === 0 ? (
                            <div className="rounded-xl border border-dashed border-border bg-card/50 p-12 text-center">
                                <Users className="h-10 w-10 text-muted-foreground/40 mx-auto mb-3" />
                                <p className="text-muted-foreground">No drivers recorded yet.</p>
                                <p className="text-sm text-muted-foreground/70 mt-1">
                                    Drivers will appear here after scans are processed.
                                </p>
                            </div>
                        ) : (
                            <div className="rounded-xl border border-border bg-card overflow-hidden">
                                <div className="grid grid-cols-12 gap-4 px-4 lg:px-6 py-3 bg-muted/30 text-xs font-medium text-muted-foreground border-b border-border uppercase tracking-wide">
                                    <div className="col-span-5 lg:col-span-4">Driver</div>
                                    <div className="col-span-2 text-center">Status</div>
                                    <div className="col-span-2 text-center">Risk</div>
                                    <div className="col-span-3 lg:col-span-4 text-right">Last Activity</div>
                                </div>
                                <div className="divide-y divide-border">
                                    {allDrivers.map((driver) => (
                                        <motion.div
                                            key={driver.fullname}
                                            initial={{ opacity: 0, x: -8 }}
                                            animate={{ opacity: 1, x: 0 }}
                                            transition={{ duration: 0.2 }}
                                        >
                                            <Link
                                                to={`/drivers/${encodeURIComponent(driver.fullname)}`}
                                                className="grid grid-cols-12 gap-4 px-4 lg:px-6 py-4 items-center hover:bg-accent/30 transition-colors group"
                                            >
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
                                                <div className="col-span-2 flex justify-center">
                                                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${driver.status === 'FIT'
                                                        ? 'bg-emerald-500/15 text-emerald-500'
                                                        : 'bg-red-500/15 text-red-500'
                                                        }`}>
                                                        {driver.status}
                                                    </span>
                                                </div>
                                                <div className="col-span-2 flex flex-col items-center">
                                                    <span className={`text-sm font-semibold ${driver.averageRiskScore >= 5 ? 'text-red-500' : 'text-emerald-500'
                                                        }`}>
                                                        {driver.averageRiskScore.toFixed(1)}
                                                    </span>
                                                    <span className={`text-xs px-1.5 py-0.5 rounded ${getRiskTier(driver.averageRiskScore) === 'LOW' ? 'text-emerald-500/70' :
                                                        getRiskTier(driver.averageRiskScore) === 'MEDIUM' ? 'text-amber-500/70' :
                                                            'text-red-500/70'
                                                        }`}>
                                                        {getRiskTier(driver.averageRiskScore)}
                                                    </span>
                                                </div>
                                                <div className="col-span-3 lg:col-span-4 flex items-center justify-end gap-2">
                                                    <span className="text-xs text-muted-foreground">
                                                        {driver.latestScan?.timestamp
                                                            ? getRelativeTime(driver.latestScan.timestamp)
                                                            : '—'}
                                                    </span>
                                                    <ChevronRight className="h-4 w-4 text-muted-foreground/50 group-hover:text-emerald-500 transition-colors" />
                                                </div>
                                            </Link>
                                        </motion.div>
                                    ))}
                                </div>
                            </div>
                        )}
                    </motion.div>
                </>
            ) : (
                <EmptyFleetState />
            )}
        </motion.div>
    );
}

// ============================================
// Component: Metric Card
// ============================================

function MetricCard({
    label,
    value,
    sublabel,
    icon,
    color = 'default',
}: {
    label: string;
    value: string | number;
    sublabel?: string;
    icon: React.ReactNode;
    color?: 'default' | 'success' | 'warning' | 'danger';
}) {
    const colorStyles = {
        default: 'border-border/50 bg-card',
        success: 'border-emerald-500/20 bg-emerald-500/5',
        warning: 'border-amber-500/20 bg-amber-500/5',
        danger: 'border-red-500/20 bg-red-500/5',
    };

    const iconColors = {
        default: 'text-muted-foreground',
        success: 'text-emerald-500',
        warning: 'text-amber-500',
        danger: 'text-red-500',
    };

    return (
        <div className={`rounded-xl border p-5 ${colorStyles[color]}`}>
            <div className="flex items-start justify-between">
                <div>
                    <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">{label}</p>
                    <p className="text-2xl lg:text-3xl font-bold text-foreground mt-1">{value}</p>
                    {sublabel && (
                        <p className="text-xs text-muted-foreground mt-1">{sublabel}</p>
                    )}
                </div>
                <div className={iconColors[color]}>{icon}</div>
            </div>
        </div>
    );
}

// ============================================
// Loading Skeleton
// ============================================

function LoadingSkeleton() {
    return (
        <div className="space-y-8">
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                {[1, 2, 3, 4].map((i) => (
                    <div key={i} className="rounded-xl border border-border bg-card p-5">
                        <div className="skeleton h-3 w-20 mb-3" />
                        <div className="skeleton h-8 w-16" />
                    </div>
                ))}
            </div>
            <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                <div className="lg:col-span-2 rounded-xl border border-border bg-card p-6">
                    <div className="skeleton h-4 w-40 mb-4" />
                    <div className="skeleton h-3 w-full mb-4" />
                    <div className="skeleton h-20 w-full" />
                </div>
                <div className="lg:col-span-3 rounded-xl border border-border bg-card p-6">
                    <div className="skeleton h-4 w-48 mb-4" />
                    <div className="space-y-3">
                        {[1, 2, 3].map((i) => (
                            <div key={i} className="skeleton h-14 w-full rounded-lg" />
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}

// ============================================
// Empty State
// ============================================

function EmptyFleetState() {
    return (
        <div className="rounded-xl border border-dashed border-border bg-card/50 p-16 text-center">
            <Shield className="h-12 w-12 text-muted-foreground/30 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-foreground mb-2">No Fleet Data</h3>
            <p className="text-sm text-muted-foreground max-w-md mx-auto">
                Fleet metrics will appear here once driver scans have been recorded.
            </p>
        </div>
    );
}

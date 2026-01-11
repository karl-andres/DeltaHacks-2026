import { motion } from 'framer-motion';
import {
    Activity,
    AlertTriangle,
    HeartPulse,
    TrendingDown,
    Users,
} from 'lucide-react';
import { PageHeader } from '@/components/layout/PageHeader';
import { StatCard, StatCardSkeleton } from '@/components/ui/StatCard';
import { ChartCard, ChartCardSkeleton } from '@/components/ui/ChartCard';
import { ErrorDisplay } from '@/components/ui/EmptyState';
import { DriverTable, DriverTableSkeltonWrapper } from '@/components/drivers/DriverTable';
import { useHomeData } from '@/hooks/useData';
import { formatNumber } from '@/lib/utils';

// Animation variants for staggered entrance
const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
        opacity: 1,
        transition: { staggerChildren: 0.08 },
    },
};

const itemVariants = {
    hidden: { opacity: 0, y: 16 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4, ease: 'easeOut' } },
};

export default function HomePage() {
    const {
        data: homeData,
        isLoading,
        error,
        refetch,
        isFetching
    } = useHomeData();

    if (error) {
        return (
            <ErrorDisplay
                error={error as Error}
                onRetry={() => refetch()}
            />
        );
    }

    return (
        <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-8"
        >
            {/* Page Header */}
            <motion.div variants={itemVariants}>
                <PageHeader
                    title="Driver Fitness Overview"
                    subtitle="Real-time biometric monitoring across the fleet"
                >
                    {isFetching && !isLoading && (
                        <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                            Updating...
                        </div>
                    )}
                </PageHeader>
            </motion.div>

            {/* KPI Cards - Only show metrics from /home API */}
            <motion.div
                variants={itemVariants}
                className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"
            >
                {isLoading ? (
                    <>
                        <StatCardSkeleton />
                        <StatCardSkeleton />
                        <StatCardSkeleton />
                        <StatCardSkeleton />
                    </>
                ) : homeData ? (
                    <>
                        <StatCard
                            title="Fleet Readiness"
                            value={formatNumber(homeData.avgFleetReadiness)}
                            unit="IVS"
                            subtitle="Avg. Integrated Vital Score"
                            icon={Activity}
                            variant={homeData.avgFleetReadiness >= 10 ? 'success' : 'warning'}
                        />
                        <StatCard
                            title="Critical Alerts"
                            value={homeData.criticalAlertCount}
                            subtitle="Low alertness detected (NAI < 8)"
                            icon={AlertTriangle}
                            variant={homeData.criticalAlertCount > 0 ? 'danger' : 'success'}
                        />
                        <StatCard
                            title="Cardio-Resp Sync"
                            value={homeData.isSystemSynced ? 'Synced' : 'Decoupled'}
                            subtitle={`Avg CRC: ${formatNumber(homeData.raw_aggregates.avg_crc)}`}
                            icon={HeartPulse}
                            variant={homeData.isSystemSynced ? 'success' : 'warning'}
                        />
                        <StatCard
                            title="Pulse Baseline"
                            value={formatNumber(homeData.raw_aggregates.avg_pulse)}
                            unit="bpm"
                            subtitle={`${homeData.fleetStressDelta >= 0 ? '+' : ''}${formatNumber(homeData.fleetStressDelta)} from 70 bpm`}
                            icon={TrendingDown}
                            variant={Math.abs(homeData.fleetStressDelta) <= 10 ? 'default' : 'warning'}
                        />
                    </>
                ) : (
                    <motion.div
                        variants={itemVariants}
                        className="col-span-full rounded-xl border border-dashed border-border bg-card/50 p-8 text-center"
                    >
                        <Activity className="h-8 w-8 mx-auto text-muted-foreground/50 mb-3" />
                        <p className="text-sm text-muted-foreground">
                            No fleet metrics available. Start recording driver scans to see data here.
                        </p>
                    </motion.div>
                )}
            </motion.div>

            {/* Fleet Summary Cards */}
            {homeData && (
                <motion.div
                    variants={itemVariants}
                    className="grid grid-cols-1 lg:grid-cols-3 gap-4"
                >
                    <ChartCard
                        title="System Status"
                        className="lg:col-span-1"
                    >
                        <div className="space-y-4 py-2">
                            <StatusRow
                                label="Cardio-Respiratory Coupling"
                                status={homeData.isSystemSynced ? 'healthy' : 'warning'}
                                detail={homeData.isSystemSynced ? 'CRC < 20 (Normal)' : 'CRC > 20 (Elevated)'}
                            />
                            <StatusRow
                                label="Fleet Alertness Level"
                                status={homeData.criticalAlertCount === 0 ? 'healthy' : 'warning'}
                                detail={homeData.criticalAlertCount === 0 ? 'All drivers alert' : `${homeData.criticalAlertCount} driver(s) with low NAI`}
                            />
                            <StatusRow
                                label="Vitality Stress"
                                status={Math.abs(homeData.fleetStressDelta) <= 10 ? 'healthy' : 'warning'}
                                detail={`${Math.abs(homeData.fleetStressDelta).toFixed(1)} bpm from baseline`}
                            />
                        </div>
                    </ChartCard>

                    <ChartCard
                        title="Aggregate Metrics"
                        className="lg:col-span-2"
                    >
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 py-2">
                            <MetricBlock
                                label="Avg Pulse"
                                value={formatNumber(homeData.raw_aggregates.avg_pulse)}
                                unit="bpm"
                            />
                            <MetricBlock
                                label="Avg CRC"
                                value={formatNumber(homeData.raw_aggregates.avg_crc)}
                            />
                            <MetricBlock
                                label="Fleet IVS"
                                value={formatNumber(homeData.avgFleetReadiness)}
                            />
                            <MetricBlock
                                label="Alerts"
                                value={homeData.criticalAlertCount}
                                variant={homeData.criticalAlertCount > 0 ? 'danger' : 'success'}
                            />
                        </div>
                    </ChartCard>
                </motion.div>
            )}

            {/* Drivers Section */}
            <motion.div variants={itemVariants}>
                <div className="flex items-center justify-between mb-4">
                    <div>
                        <h2 className="text-lg font-semibold text-foreground flex items-center gap-2">
                            <Users className="h-5 w-5 text-muted-foreground" />
                            Driver Fleet
                        </h2>
                        <p className="text-sm text-muted-foreground mt-0.5">
                            Click any driver to view detailed scan history
                        </p>
                    </div>
                    <button
                        onClick={() => refetch()}
                        disabled={isFetching}
                        className="text-sm text-muted-foreground hover:text-foreground transition-colors disabled:opacity-50"
                    >
                        {isFetching ? 'Refreshing...' : 'Refresh'}
                    </button>
                </div>

                {isLoading ? (
                    <DriverTableSkeltonWrapper />
                ) : (
                    <DriverTable />
                )}
            </motion.div>
        </motion.div>
    );
}

// ============================================
// Helper Components
// ============================================

function StatusRow({
    label,
    status,
    detail
}: {
    label: string;
    status: 'healthy' | 'warning' | 'danger';
    detail: string;
}) {
    const colors = {
        healthy: 'bg-emerald-500',
        warning: 'bg-amber-500',
        danger: 'bg-red-500',
    };

    return (
        <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
                <span className={`h-2 w-2 rounded-full ${colors[status]}`} />
                <span className="text-sm text-foreground">{label}</span>
            </div>
            <span className="text-xs text-muted-foreground">{detail}</span>
        </div>
    );
}

function MetricBlock({
    label,
    value,
    unit,
    variant = 'default'
}: {
    label: string;
    value: string | number;
    unit?: string;
    variant?: 'default' | 'success' | 'danger';
}) {
    const valueColors = {
        default: 'text-foreground',
        success: 'text-emerald-500',
        danger: 'text-red-500',
    };

    return (
        <div className="text-center p-3 rounded-lg bg-muted/30">
            <p className="text-xs text-muted-foreground mb-1">{label}</p>
            <p className={`text-xl font-semibold ${valueColors[variant]}`}>
                {value}
                {unit && <span className="text-sm font-normal text-muted-foreground ml-1">{unit}</span>}
            </p>
        </div>
    );
}

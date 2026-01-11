import { useState, useMemo } from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Activity,
    ChevronLeft,
    ClipboardList,
    Heart,
    LineChart,
    RefreshCw,
    Wind,
    Zap,
} from 'lucide-react';
import { PageLoader } from '@/components/ui/PageLoader';
import { DriverNotFound, ErrorDisplay } from '@/components/ui/EmptyState';
import { ChartCard } from '@/components/ui/ChartCard';
import { StatCard } from '@/components/ui/StatCard';
import { Tabs } from '@/components/ui/Tabs';
import { Avatar } from '@/components/ui/Avatar';
import { StatusBadge, RiskBadge } from '@/components/ui/Badge';
import { ProgressRing } from '@/components/ui/ProgressRing';
import { ScanHistoryTable } from '@/components/drivers/ScanHistoryTable';
import { VitalsTrendChart } from '@/components/charts/VitalsTrendChart';
import { RiskScoreChart } from '@/components/charts/RiskScoreChart';
import { MetricsChart } from '@/components/charts/MetricsChart';
import { useDriverData, computeDriverSummary, computeDriverStats } from '@/hooks/useData';
import { getRiskTier } from '@/types';
import { formatNumber, getRelativeTime } from '@/lib/utils';

const tabConfig = [
    { id: 'overview', label: 'Overview', icon: <Activity className="h-4 w-4" /> },
    { id: 'history', label: 'Scans', icon: <ClipboardList className="h-4 w-4" /> },
    { id: 'metrics', label: 'Metrics', icon: <LineChart className="h-4 w-4" /> },
];

// Animation variants
const pageVariants = {
    hidden: { opacity: 0 },
    visible: { opacity: 1, transition: { staggerChildren: 0.1 } },
};

const itemVariants = {
    hidden: { opacity: 0, y: 12 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
};

export default function DriverPage() {
    const { fullName } = useParams<{ fullName: string }>();
    const decodedName = fullName ? decodeURIComponent(fullName) : '';

    const [activeTab, setActiveTab] = useState('overview');

    const { data: scans, isLoading, error, refetch, isFetching } = useDriverData(decodedName);

    // Compute derived data from scans
    const driverSummary = useMemo(() => computeDriverSummary(scans), [scans]);
    const driverStats = useMemo(() => computeDriverStats(scans), [scans]);

    if (isLoading) {
        return <PageLoader />;
    }

    if (error) {
        return <ErrorDisplay error={error as Error} onRetry={() => refetch()} />;
    }

    if (!scans || scans.length === 0 || !driverSummary) {
        return <DriverNotFound />;
    }

    const riskTier = getRiskTier(driverSummary.averageRiskScore);
    const safetyScore = Math.max(0, 100 - driverSummary.averageRiskScore * 10);

    return (
        <motion.div
            variants={pageVariants}
            initial="hidden"
            animate="visible"
            className="space-y-6"
        >
            {/* Breadcrumb */}
            <motion.div variants={itemVariants}>
                <Link
                    to="/home"
                    className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors group"
                >
                    <ChevronLeft className="h-4 w-4 group-hover:-translate-x-0.5 transition-transform" />
                    Back to Dashboard
                </Link>
            </motion.div>

            {/* Driver Header Card */}
            <motion.div
                variants={itemVariants}
                className="rounded-xl border border-border bg-gradient-to-br from-card via-card to-card/80 p-6"
            >
                <div className="flex flex-col lg:flex-row lg:items-center gap-6">
                    {/* Left: Driver Info */}
                    <div className="flex items-start gap-4 flex-1">
                        <Avatar name={driverSummary.fullname} size="lg" />
                        <div className="min-w-0">
                            <h1 className="text-xl lg:text-2xl font-bold text-foreground truncate">
                                {driverSummary.fullname}
                            </h1>
                            <div className="flex flex-wrap items-center gap-2 mt-2">
                                <StatusBadge status={driverSummary.status} />
                                <RiskBadge tier={riskTier} />
                                <span className="text-xs text-muted-foreground">
                                    ID: {driverSummary.driver_id}
                                </span>
                            </div>
                            <p className="text-sm text-muted-foreground mt-2">
                                {driverSummary.scanCount} scan{driverSummary.scanCount !== 1 ? 's' : ''} recorded
                                {driverSummary.latestScan && (
                                    <> · Last: {getRelativeTime(driverSummary.latestScan.timestamp)}</>
                                )}
                            </p>
                        </div>
                    </div>

                    {/* Right: Score & Stats */}
                    <div className="flex items-center gap-6 lg:gap-8">
                        <ProgressRing
                            value={safetyScore}
                            max={100}
                            size={80}
                            strokeWidth={6}
                            label="/100"
                        />
                        <div className="hidden sm:block h-16 w-px bg-border" />
                        <div className="hidden sm:grid grid-cols-2 gap-4 text-center">
                            <div>
                                <p className="text-xs text-muted-foreground uppercase tracking-wide">Avg IVS</p>
                                <p className="text-lg font-semibold text-foreground mt-0.5">
                                    {formatNumber(driverSummary.averageIVS)}
                                </p>
                            </div>
                            <div>
                                <p className="text-xs text-muted-foreground uppercase tracking-wide">Avg Risk</p>
                                <p className={`text-lg font-semibold mt-0.5 ${driverSummary.averageRiskScore >= 5 ? 'text-red-500' : 'text-emerald-500'
                                    }`}>
                                    {formatNumber(driverSummary.averageRiskScore)}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </motion.div>

            {/* Tabs + Refresh */}
            <motion.div variants={itemVariants} className="flex items-center justify-between">
                <Tabs
                    tabs={tabConfig}
                    activeTab={activeTab}
                    onTabChange={setActiveTab}
                />
                <button
                    onClick={() => refetch()}
                    disabled={isFetching}
                    className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors disabled:opacity-50"
                >
                    <RefreshCw className={`h-4 w-4 ${isFetching ? 'animate-spin' : ''}`} />
                    {isFetching ? 'Refreshing' : 'Refresh'}
                </button>
            </motion.div>

            {/* Tab Content */}
            <AnimatePresence mode="wait">
                <motion.div
                    key={activeTab}
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -8 }}
                    transition={{ duration: 0.25 }}
                >
                    {activeTab === 'overview' && (
                        <OverviewTab scans={scans} stats={driverStats} />
                    )}
                    {activeTab === 'history' && (
                        <HistoryTab scans={scans} />
                    )}
                    {activeTab === 'metrics' && (
                        <MetricsTab scans={scans} stats={driverStats} />
                    )}
                </motion.div>
            </AnimatePresence>
        </motion.div>
    );
}

// ============================================
// Tab Components - Only display real data
// ============================================

function OverviewTab({
    scans,
    stats
}: {
    scans: NonNullable<ReturnType<typeof useDriverData>['data']>;
    stats: ReturnType<typeof computeDriverStats>;
}) {
    if (!stats) {
        return (
            <div className="rounded-xl border border-dashed border-border p-8 text-center text-muted-foreground">
                Insufficient data to display statistics.
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Stats Cards */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard
                    title="Avg Pulse"
                    value={formatNumber(stats.avgPulse)}
                    unit="bpm"
                    icon={Heart}
                    variant={stats.avgPulse < 50 || stats.avgPulse > 100 ? 'warning' : 'default'}
                />
                <StatCard
                    title="Avg Breathing"
                    value={formatNumber(stats.avgBreathing)}
                    unit="rpm"
                    icon={Wind}
                    variant={stats.avgBreathing < 8 || stats.avgBreathing > 25 ? 'warning' : 'default'}
                />
                <StatCard
                    title="Vital Score"
                    value={formatNumber(stats.avgIVS)}
                    subtitle="Integrated (IVS)"
                    icon={Activity}
                    variant="success"
                />
                <StatCard
                    title="Alertness"
                    value={formatNumber(stats.avgNAI)}
                    subtitle="Nonlinear (NAI)"
                    icon={Zap}
                    variant={stats.avgNAI < 8 ? 'warning' : 'success'}
                />
            </div>

            {/* Charts */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <ChartCard title="Vital Signs" subtitle="Pulse and breathing over time">
                    <VitalsTrendChart scans={scans} height={260} />
                </ChartCard>
                <ChartCard title="Risk Score" subtitle="Safety assessment trend">
                    <RiskScoreChart scans={scans} height={260} />
                </ChartCard>
            </div>

            {/* Recent Scans */}
            <ChartCard title="Recent Scans" subtitle={`Latest ${Math.min(5, scans.length)} of ${scans.length}`}>
                <ScanHistoryTable scans={scans.slice(0, 5)} />
            </ChartCard>
        </div>
    );
}

function HistoryTab({ scans }: { scans: NonNullable<ReturnType<typeof useDriverData>['data']> }) {
    return (
        <div className="space-y-4">
            <p className="text-sm text-muted-foreground">
                {scans.length} scan{scans.length !== 1 ? 's' : ''} recorded
            </p>
            <ScanHistoryTable scans={scans} />
        </div>
    );
}

function MetricsTab({
    scans,
    stats
}: {
    scans: NonNullable<ReturnType<typeof useDriverData>['data']>;
    stats: ReturnType<typeof computeDriverStats>;
}) {
    if (!stats) {
        return (
            <div className="rounded-xl border border-dashed border-border p-8 text-center text-muted-foreground">
                Insufficient data for advanced metrics.
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Derived Metrics */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <MetricCard
                    label="PRQ"
                    value={formatNumber(stats.avgPRQ, 2)}
                    description="Pulse-Respiration Quotient"
                    status={stats.avgPRQ >= 3.2 && stats.avgPRQ <= 5.5 ? 'normal' : 'warning'}
                    range="3.2 – 5.5"
                />
                <MetricCard
                    label="IVS"
                    value={formatNumber(stats.avgIVS)}
                    description="Integrated Vital Score"
                    status="normal"
                    range="> 6.5"
                />
                <MetricCard
                    label="CRC"
                    value={formatNumber(stats.avgCRC)}
                    description="Cardio-Respiratory Coupler"
                    status={stats.avgCRC <= 20 ? 'normal' : 'warning'}
                    range="< 20"
                />
                <MetricCard
                    label="NAI"
                    value={formatNumber(stats.avgNAI)}
                    description="Nonlinear Alertness Index"
                    status={stats.avgNAI >= 8 ? 'normal' : 'warning'}
                    range="> 8.0"
                />
            </div>

            {/* Metrics Chart */}
            <ChartCard title="Derived Metrics Trend" subtitle="PRQ, IVS, NAI over time">
                <MetricsChart scans={scans} height={320} />
            </ChartCard>
        </div>
    );
}

function MetricCard({
    label,
    value,
    description,
    status,
    range
}: {
    label: string;
    value: string;
    description: string;
    status: 'normal' | 'warning';
    range: string;
}) {
    return (
        <div className="rounded-xl border border-border bg-card p-4">
            <div className="flex items-start justify-between">
                <span className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                    {label}
                </span>
                <span className={`h-2 w-2 rounded-full ${status === 'normal' ? 'bg-emerald-500' : 'bg-amber-500'
                    }`} />
            </div>
            <p className="text-2xl font-bold text-foreground mt-2">{value}</p>
            <p className="text-xs text-muted-foreground mt-1">{description}</p>
            <p className="text-xs text-muted-foreground/70 mt-0.5">Normal: {range}</p>
        </div>
    );
}

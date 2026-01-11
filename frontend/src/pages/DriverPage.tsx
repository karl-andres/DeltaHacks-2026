import { useState, useMemo } from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Activity,
    ChevronLeft,
    ClipboardList,
    RefreshCw,
    CheckCircle2,
    AlertTriangle,
    XCircle,
} from 'lucide-react';
import { PageLoader } from '@/components/ui/PageLoader';
import { DriverNotFound, ErrorDisplay } from '@/components/ui/EmptyState';
import { ChartCard } from '@/components/ui/ChartCard';
import { Tabs } from '@/components/ui/Tabs';
import { Avatar } from '@/components/ui/Avatar';
import { StatusBadge, RiskBadge } from '@/components/ui/Badge';
import { ProgressRing } from '@/components/ui/ProgressRing';
import { ScanHistoryTable } from '@/components/drivers/ScanHistoryTable';
import { VitalsChart } from '@/components/charts/VitalsChart';
import { useDriverData, computeDriverSummary, computeDriverStats } from '@/hooks/useData';
import { getRiskTier } from '@/types';
import { formatNumber, getRelativeTime } from '@/lib/utils';

// Only 2 tabs: Overview (all metrics + charts) and History (scan records)
const tabConfig = [
    { id: 'overview', label: 'Overview', icon: <Activity className="h-4 w-4" /> },
    { id: 'history', label: 'Scan History', icon: <ClipboardList className="h-4 w-4" /> },
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
    const safetyScore = Math.max(0, Math.round(100 - driverSummary.averageRiskScore * 10));

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
                    Back to Fleet Overview
                </Link>
            </motion.div>

            {/* Driver Header */}
            <motion.div
                variants={itemVariants}
                className="rounded-xl border border-border bg-gradient-to-br from-card via-card to-card/80 p-6"
            >
                <div className="flex flex-col lg:flex-row lg:items-center gap-6">
                    {/* Driver Info */}
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

                    {/* Safety Score */}
                    <div className="flex items-center gap-6">
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
                                <p className="text-xs text-muted-foreground uppercase tracking-wide">Avg Risk</p>
                                <p className={`text-lg font-semibold mt-0.5 ${driverSummary.averageRiskScore >= 5 ? 'text-red-500' : 'text-emerald-500'
                                    }`}>
                                    {formatNumber(driverSummary.averageRiskScore)}
                                </p>
                            </div>
                            <div>
                                <p className="text-xs text-muted-foreground uppercase tracking-wide">Avg IVS</p>
                                <p className="text-lg font-semibold text-foreground mt-0.5">
                                    {formatNumber(driverSummary.averageIVS)}
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
                        <OverviewTab scans={scans} stats={driverStats} summary={driverSummary} />
                    )}
                    {activeTab === 'history' && (
                        <HistoryTab scans={scans} />
                    )}
                </motion.div>
            </AnimatePresence>
        </motion.div>
    );
}

// ============================================
// OVERVIEW TAB - Status + All Averages + Charts
// ============================================

function OverviewTab({
    scans,
    stats,
    summary,
}: {
    scans: NonNullable<ReturnType<typeof useDriverData>['data']>;
    stats: ReturnType<typeof computeDriverStats>;
    summary: NonNullable<ReturnType<typeof computeDriverSummary>>;
}) {
    if (!stats) {
        return (
            <div className="rounded-xl border border-dashed border-border p-8 text-center text-muted-foreground">
                Insufficient data to display overview.
            </div>
        );
    }

    // Derive overall assessment from averages
    const isHealthy = summary.averageRiskScore < 5;
    const alertnessOk = stats.avgNAI >= 8;
    const crcOk = stats.avgCRC < 20;
    const issueCount = [!isHealthy, !alertnessOk, !crcOk].filter(Boolean).length;
    const overallStatus = issueCount === 0 ? 'healthy' : issueCount === 1 ? 'warning' : 'critical';

    return (
        <div className="space-y-6">
            {/* Status Assessment */}
            <StatusCard status={overallStatus} />

            {/* All Average Metrics - Consistent treatment */}
            <div className="rounded-xl border border-border bg-card p-6">
                <h3 className="text-sm font-semibold text-foreground mb-4">
                    Average Metrics ({scans.length} scan{scans.length !== 1 ? 's' : ''})
                </h3>

                <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                    {/* Measured vitals */}
                    <MetricItem
                        label="Avg Pulse Rate"
                        value={formatNumber(stats.avgPulse)}
                        unit="bpm"
                        status={stats.avgPulse >= 50 && stats.avgPulse <= 100 ? 'normal' : 'warning'}
                    />
                    <MetricItem
                        label="Avg Breathing Rate"
                        value={formatNumber(stats.avgBreathing)}
                        unit="rpm"
                        status={stats.avgBreathing >= 8 && stats.avgBreathing <= 25 ? 'normal' : 'warning'}
                    />

                    {/* Computed metrics */}
                    <MetricItem
                        label="Avg CRC"
                        value={formatNumber(stats.avgCRC)}
                        status={stats.avgCRC < 20 ? 'normal' : 'warning'}
                    />
                    <MetricItem
                        label="Avg NAI"
                        value={formatNumber(stats.avgNAI)}
                        status={stats.avgNAI >= 8 ? 'normal' : 'warning'}
                    />
                    <MetricItem
                        label="Avg PRQ"
                        value={formatNumber(stats.avgPRQ, 2)}
                        status={stats.avgPRQ >= 3.2 && stats.avgPRQ <= 5.5 ? 'normal' : 'warning'}
                    />
                    <MetricItem
                        label="Avg IVS"
                        value={formatNumber(stats.avgIVS)}
                        status={stats.avgIVS >= 6.5 ? 'normal' : 'warning'}
                    />
                    <MetricItem
                        label="Avg Risk Score"
                        value={formatNumber(stats.avgRiskScore)}
                        status={stats.avgRiskScore < 5 ? 'normal' : 'warning'}
                    />
                </div>
            </div>

            {/* Charts */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <ChartCard title="Vitals Over Time" subtitle="Pulse Rate and CRC from each scan">
                    <VitalsChart scans={scans} metrics={['pulse', 'crc']} height={280} />
                </ChartCard>
                <ChartCard title="Performance Metrics" subtitle="NAI, IVS, and Risk Score trends">
                    <VitalsChart scans={scans} metrics={['nai', 'ivs', 'risk']} height={280} />
                </ChartCard>
            </div>
        </div>
    );
}

function StatusCard({ status }: { status: 'healthy' | 'warning' | 'critical' }) {
    const config = {
        healthy: {
            icon: CheckCircle2,
            title: 'Driver is Fit',
            description: 'All average indicators are within normal ranges.',
            className: 'border-emerald-500/30 bg-emerald-500/5',
            iconColor: 'text-emerald-500',
        },
        warning: {
            icon: AlertTriangle,
            title: 'Needs Attention',
            description: 'One or more indicators are slightly outside normal ranges.',
            className: 'border-amber-500/30 bg-amber-500/5',
            iconColor: 'text-amber-500',
        },
        critical: {
            icon: XCircle,
            title: 'Critical Status',
            description: 'Multiple indicators are concerning. Review recommended.',
            className: 'border-red-500/30 bg-red-500/5',
            iconColor: 'text-red-500',
        },
    };

    const { icon: Icon, title, description, className, iconColor } = config[status];

    return (
        <div className={`rounded-xl border p-5 ${className}`}>
            <div className="flex items-center gap-3">
                <Icon className={`h-6 w-6 ${iconColor}`} />
                <div>
                    <h3 className="text-lg font-semibold text-foreground">{title}</h3>
                    <p className="text-sm text-muted-foreground">{description}</p>
                </div>
            </div>
        </div>
    );
}

function MetricItem({
    label,
    value,
    unit,
    status,
}: {
    label: string;
    value: string;
    unit?: string;
    status: 'normal' | 'warning';
}) {
    return (
        <div className="flex items-center justify-between p-3 rounded-lg bg-muted/30">
            <div className="flex items-center gap-2">
                <span className={`h-2 w-2 rounded-full ${status === 'normal' ? 'bg-emerald-500' : 'bg-amber-500'}`} />
                <span className="text-sm text-muted-foreground">{label}</span>
            </div>
            <span className="text-sm font-semibold text-foreground">
                {value}{unit && <span className="text-muted-foreground font-normal ml-1">{unit}</span>}
            </span>
        </div>
    );
}

// ============================================
// HISTORY TAB - Scan records
// ============================================

function HistoryTab({ scans }: { scans: NonNullable<ReturnType<typeof useDriverData>['data']> }) {
    return (
        <div className="space-y-4">
            <p className="text-sm text-muted-foreground">
                Showing all {scans.length} scan{scans.length !== 1 ? 's' : ''} for this driver
            </p>
            <ScanHistoryTable scans={scans} />
        </div>
    );
}

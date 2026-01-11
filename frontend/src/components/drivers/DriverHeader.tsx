import { motion } from 'framer-motion';
import { ChevronLeft } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Avatar } from '@/components/ui/Avatar';
import { StatusBadge, RiskBadge } from '@/components/ui/Badge';
import { ProgressRing } from '@/components/ui/ProgressRing';
import { DriverSummary, getRiskTier } from '@/types';
import { formatNumber, getRelativeTime } from '@/lib/utils';

interface DriverHeaderProps {
    driver: DriverSummary;
}

export function DriverHeader({ driver }: DriverHeaderProps) {
    const riskTier = getRiskTier(driver.averageRiskScore);
    const latestScan = driver.latestScan;

    return (
        <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="rounded-xl border border-border bg-gradient-to-br from-card to-card/50 p-6"
        >
            {/* Breadcrumb */}
            <Link
                to="/home"
                className="inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-primary transition-colors mb-6"
            >
                <ChevronLeft className="h-4 w-4" />
                Back to Dashboard
            </Link>

            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
                {/* Left: Driver Info */}
                <div className="flex items-center gap-4">
                    <div className="relative">
                        <Avatar name={driver.fullname} size="xl" />
                        <span
                            className={`absolute bottom-0 right-0 h-4 w-4 rounded-full border-2 border-card ${driver.status === 'FIT' ? 'bg-green-500 animate-pulse' : 'bg-red-500'
                                }`}
                        />
                    </div>
                    <div>
                        <div className="flex items-center gap-3 flex-wrap">
                            <h1 className="text-2xl font-bold text-foreground">
                                {driver.fullname}
                            </h1>
                            <span className="text-sm text-muted-foreground bg-muted px-2 py-0.5 rounded">
                                ID: #{driver.driver_id}
                            </span>
                        </div>
                        <div className="flex items-center gap-3 mt-2 flex-wrap">
                            <StatusBadge status={driver.status} />
                            <RiskBadge tier={riskTier} />
                            {latestScan && (
                                <span className="text-sm text-muted-foreground">
                                    Last scan: {getRelativeTime(latestScan.timestamp)}
                                </span>
                            )}
                        </div>
                        <p className="text-sm text-muted-foreground mt-2">
                            {driver.scanCount} total scans recorded
                        </p>
                    </div>
                </div>

                {/* Right: Score Ring */}
                <div className="flex items-center gap-6">
                    <div className="text-center">
                        <ProgressRing
                            value={Math.max(0, 100 - driver.averageRiskScore * 10)}
                            max={100}
                            size={100}
                            label="Safety"
                        />
                        <p className="mt-2 text-sm text-muted-foreground">Safety Score</p>
                    </div>
                    <div className="hidden sm:block h-16 w-px bg-border" />
                    <div className="hidden sm:flex flex-col gap-2">
                        <div>
                            <p className="text-sm text-muted-foreground">Avg. Vital Score</p>
                            <p className="text-xl font-semibold text-foreground">
                                {formatNumber(driver.averageIVS)}
                            </p>
                        </div>
                        <div>
                            <p className="text-sm text-muted-foreground">Avg. Risk Score</p>
                            <p className={`text-xl font-semibold ${driver.averageRiskScore >= 5 ? 'text-red-500' : 'text-green-500'
                                }`}>
                                {formatNumber(driver.averageRiskScore)}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </motion.div>
    );
}

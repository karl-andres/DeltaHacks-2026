import { cn } from '@/lib/utils';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
    title: string;
    value: string | number;
    unit?: string;
    subtitle?: string;
    icon?: LucideIcon;
    variant?: 'default' | 'success' | 'warning' | 'danger';
}

const variantStyles = {
    default: {
        card: 'border-border/50 bg-card',
        icon: 'bg-muted text-muted-foreground',
    },
    success: {
        card: 'border-emerald-500/20 bg-gradient-to-br from-emerald-500/5 to-transparent',
        icon: 'bg-emerald-500/15 text-emerald-500',
    },
    warning: {
        card: 'border-amber-500/20 bg-gradient-to-br from-amber-500/5 to-transparent',
        icon: 'bg-amber-500/15 text-amber-500',
    },
    danger: {
        card: 'border-red-500/20 bg-gradient-to-br from-red-500/5 to-transparent',
        icon: 'bg-red-500/15 text-red-500',
    },
};

export function StatCard({
    title,
    value,
    unit,
    subtitle,
    icon: Icon,
    variant = 'default',
}: StatCardProps) {
    const styles = variantStyles[variant];

    return (
        <div
            className={cn(
                'rounded-xl border p-4 lg:p-5 transition-colors',
                styles.card
            )}
        >
            <div className="flex items-start justify-between">
                <div className="flex-1 min-w-0">
                    <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                        {title}
                    </p>
                    <p className="mt-2 text-2xl lg:text-3xl font-bold tracking-tight text-foreground">
                        {value}
                        {unit && (
                            <span className="text-base lg:text-lg font-normal text-muted-foreground ml-1">
                                {unit}
                            </span>
                        )}
                    </p>
                    {subtitle && (
                        <p className="mt-1 text-xs text-muted-foreground truncate">{subtitle}</p>
                    )}
                </div>
                {Icon && (
                    <div className={cn('rounded-lg p-2', styles.icon)}>
                        <Icon className="h-4 w-4 lg:h-5 lg:w-5" />
                    </div>
                )}
            </div>
        </div>
    );
}

export function StatCardSkeleton() {
    return (
        <div className="rounded-xl border border-border bg-card p-4 lg:p-5">
            <div className="flex items-start justify-between">
                <div className="flex-1">
                    <div className="skeleton h-3 w-20" />
                    <div className="skeleton mt-3 h-7 w-16" />
                    <div className="skeleton mt-2 h-3 w-28" />
                </div>
                <div className="skeleton h-9 w-9 rounded-lg" />
            </div>
        </div>
    );
}

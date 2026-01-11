import { cn } from '@/lib/utils';
import { RiskTier } from '@/types';

interface BadgeProps {
    children: React.ReactNode;
    variant?: 'default' | 'success' | 'warning' | 'danger' | 'outline';
    size?: 'sm' | 'md';
    className?: string;
}

const variantStyles = {
    default: 'bg-primary/20 text-primary border-primary/30',
    success: 'bg-green-500/20 text-green-500 border-green-500/30',
    warning: 'bg-amber-500/20 text-amber-500 border-amber-500/30',
    danger: 'bg-red-500/20 text-red-500 border-red-500/30',
    outline: 'bg-transparent text-muted-foreground border-border',
};

const sizeStyles = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-1 text-sm',
};

export function Badge({
    children,
    variant = 'default',
    size = 'sm',
    className,
}: BadgeProps) {
    return (
        <span
            className={cn(
                'inline-flex items-center rounded-full border font-medium',
                variantStyles[variant],
                sizeStyles[size],
                className
            )}
        >
            {children}
        </span>
    );
}

export function StatusBadge({ status }: { status: 'FIT' | 'UNFIT' | 'UNKNOWN' | 'PASS' | 'FAIL' }) {
    const variant = status === 'FIT' || status === 'PASS' ? 'success' : status === 'UNFIT' || status === 'FAIL' ? 'danger' : 'outline';
    return <Badge variant={variant}>{status}</Badge>;
}

export function RiskBadge({ tier }: { tier: RiskTier }) {
    const variantMap: Record<RiskTier, BadgeProps['variant']> = {
        LOW: 'success',
        MEDIUM: 'warning',
        HIGH: 'danger',
        CRITICAL: 'danger',
    };
    return <Badge variant={variantMap[tier]}>{tier} RISK</Badge>;
}

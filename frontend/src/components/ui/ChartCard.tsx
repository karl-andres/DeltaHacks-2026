import { cn } from '@/lib/utils';

interface ChartCardProps {
    title: string;
    subtitle?: string;
    children: React.ReactNode;
    className?: string;
}

export function ChartCard({
    title,
    subtitle,
    children,
    className,
}: ChartCardProps) {
    return (
        <div
            className={cn(
                'rounded-xl border border-border bg-card p-5 lg:p-6',
                className
            )}
        >
            <div className="mb-4">
                <h3 className="text-sm font-semibold text-foreground">{title}</h3>
                {subtitle && (
                    <p className="mt-0.5 text-xs text-muted-foreground">{subtitle}</p>
                )}
            </div>
            <div className="w-full">{children}</div>
        </div>
    );
}

export function ChartCardSkeleton({ height = 280 }: { height?: number }) {
    return (
        <div className="rounded-xl border border-border bg-card p-5 lg:p-6">
            <div className="mb-4">
                <div className="skeleton h-4 w-28" />
                <div className="skeleton mt-1 h-3 w-40" />
            </div>
            <div className="skeleton w-full rounded-lg" style={{ height }} />
        </div>
    );
}

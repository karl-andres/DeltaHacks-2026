import { motion } from 'framer-motion';
import { AlertTriangle, RefreshCw, UserX, FileX } from 'lucide-react';

interface EmptyStateProps {
    type: 'error' | 'not-found' | 'no-data';
    title: string;
    description?: string;
    action?: {
        label: string;
        onClick: () => void;
    };
}

const icons = {
    error: AlertTriangle,
    'not-found': UserX,
    'no-data': FileX,
};

export function EmptyState({ type, title, description, action }: EmptyStateProps) {
    const Icon = icons[type];

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex flex-col items-center justify-center py-16 px-4 text-center"
        >
            <div className="rounded-full bg-muted p-4 mb-4">
                <Icon className="h-8 w-8 text-muted-foreground" />
            </div>
            <h3 className="text-lg font-semibold text-foreground">{title}</h3>
            {description && (
                <p className="mt-2 max-w-md text-sm text-muted-foreground">{description}</p>
            )}
            {action && (
                <button
                    onClick={action.onClick}
                    className="mt-6 inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
                >
                    <RefreshCw className="h-4 w-4" />
                    {action.label}
                </button>
            )}
        </motion.div>
    );
}

export function ErrorDisplay({
    error,
    onRetry,
}: {
    error: Error;
    onRetry?: () => void;
}) {
    return (
        <EmptyState
            type="error"
            title="Something went wrong"
            description={error.message || 'An unexpected error occurred. Please try again.'}
            action={onRetry ? { label: 'Try Again', onClick: onRetry } : undefined}
        />
    );
}

export function DriverNotFound() {
    return (
        <EmptyState
            type="not-found"
            title="Driver Not Found"
            description="The driver you're looking for doesn't exist or has no scan data."
        />
    );
}

export function NoData({ message }: { message?: string }) {
    return (
        <EmptyState
            type="no-data"
            title="No Data Available"
            description={message || 'There is no data to display at this time.'}
        />
    );
}

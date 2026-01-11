import { motion } from 'framer-motion';
import { Activity } from 'lucide-react';

export function PageLoader() {
    return (
        <div className="flex min-h-[60vh] items-center justify-center">
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="flex flex-col items-center gap-4"
            >
                <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
                    className="rounded-full bg-gradient-to-tr from-primary to-emerald-400 p-3"
                >
                    <Activity className="h-6 w-6 text-white" />
                </motion.div>
                <p className="text-sm text-muted-foreground">Loading...</p>
            </motion.div>
        </div>
    );
}

export function Spinner({ size = 'md' }: { size?: 'sm' | 'md' | 'lg' }) {
    const sizeClasses = {
        sm: 'h-4 w-4',
        md: 'h-6 w-6',
        lg: 'h-8 w-8',
    };

    return (
        <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
            className={`rounded-full border-2 border-primary border-t-transparent ${sizeClasses[size]}`}
        />
    );
}

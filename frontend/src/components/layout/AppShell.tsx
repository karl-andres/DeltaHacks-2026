import { Link, useLocation } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Activity, Shield } from 'lucide-react';
import { cn } from '@/lib/utils';

interface AppShellProps {
    children: React.ReactNode;
}

export function AppShell({ children }: AppShellProps) {
    const location = useLocation();
    const isHome = location.pathname === '/home' || location.pathname === '/';
    const isDriverPage = location.pathname.startsWith('/drivers');

    return (
        <div className="min-h-screen bg-background">
            {/* Top Navigation */}
            <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur-md">
                <div className="container mx-auto flex h-14 items-center justify-between px-4 lg:px-6">
                    {/* Logo */}
                    <Link to="/home" className="flex items-center gap-2.5 group">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-emerald-500 to-green-600 shadow-lg shadow-emerald-500/20 group-hover:shadow-emerald-500/40 transition-shadow">
                            <Shield className="h-4 w-4 text-white" />
                        </div>
                        <span className="text-lg font-semibold tracking-tight">
                            <span className="text-emerald-500">Fleet</span>
                            <span className="text-foreground">Guard</span>
                        </span>
                    </Link>

                    {/* Navigation Links */}
                    <nav className="flex items-center gap-1">
                        <Link
                            to="/home"
                            className={cn(
                                'relative px-3 py-1.5 text-sm font-medium rounded-md transition-colors',
                                isHome
                                    ? 'text-foreground'
                                    : 'text-muted-foreground hover:text-foreground'
                            )}
                        >
                            <span className="flex items-center gap-1.5">
                                <Activity className="h-4 w-4" />
                                Dashboard
                            </span>
                            {isHome && (
                                <motion.div
                                    layoutId="nav-underline"
                                    className="absolute inset-x-1 -bottom-[0.95rem] h-0.5 bg-emerald-500 rounded-full"
                                    transition={{ type: 'spring', stiffness: 400, damping: 30 }}
                                />
                            )}
                        </Link>
                        {isDriverPage && (
                            <span className="text-muted-foreground/50 px-1">/</span>
                        )}
                        {isDriverPage && (
                            <span className="text-sm text-foreground font-medium">
                                Driver Details
                            </span>
                        )}
                    </nav>
                </div>
            </header>

            {/* Main Content */}
            <main className="container mx-auto px-4 lg:px-6 py-6 lg:py-8">
                {children}
            </main>
        </div>
    );
}

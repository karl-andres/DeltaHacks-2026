import { Routes, Route, Navigate } from 'react-router-dom'
import { Suspense, lazy } from 'react'
import { AppShell } from '@/components/layout/AppShell'
import { PageLoader } from '@/components/ui/PageLoader'
import { ErrorBoundary } from '@/components/ErrorBoundary'

// Lazy load pages for code splitting
const HomePage = lazy(() => import('@/pages/HomePage'))
const DriverPage = lazy(() => import('@/pages/DriverPage'))

function App() {
    return (
        <ErrorBoundary>
            <AppShell>
                <Suspense fallback={<PageLoader />}>
                    <Routes>
                        <Route path="/" element={<Navigate to="/home" replace />} />
                        <Route path="/home" element={<HomePage />} />
                        <Route path="/drivers/:fullName" element={<DriverPage />} />
                        <Route path="*" element={<Navigate to="/home" replace />} />
                    </Routes>
                </Suspense>
            </AppShell>
        </ErrorBoundary>
    )
}

export default App

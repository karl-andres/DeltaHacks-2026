# FleetGuard - Driver Fitness Dashboard

A modern, professional-grade frontend dashboard for monitoring driver fitness, health metrics, and safety analytics.

## 🚀 Tech Stack

- **Framework**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS + Custom Design System
- **State Management**: TanStack Query (React Query) v5
- **Routing**: React Router v6
- **Animations**: Framer Motion
- **Charts**: Recharts
- **Icons**: Lucide React

## 📁 Project Structure

```
frontend/
├── public/
│   └── vite.svg
├── src/
│   ├── components/
│   │   ├── charts/          # Chart components (VitalsTrendChart, RiskScoreChart, etc.)
│   │   ├── drivers/         # Driver-specific components (DriverTable, DriverHeader, etc.)
│   │   ├── layout/          # Layout components (AppShell, PageHeader)
│   │   └── ui/              # Reusable UI components (StatCard, Badge, Button, etc.)
│   ├── hooks/               # Custom React hooks (useData)
│   ├── lib/                 # Utilities and API client
│   │   ├── api.ts           # API client with error handling
│   │   └── utils.ts         # Utility functions
│   ├── pages/               # Page components
│   │   ├── HomePage.tsx     # /home route
│   │   └── DriverPage.tsx   # /drivers/:fullName route
│   ├── types/               # TypeScript type definitions
│   ├── App.tsx              # Main app with routing
│   ├── main.tsx             # Entry point with providers
│   └── index.css            # Global styles and Tailwind config
├── .env                     # Environment variables
├── .env.example             # Example environment variables
├── package.json
├── tailwind.config.js
├── tsconfig.json
└── vite.config.ts
```

## 🛠️ Setup & Installation

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Backend API running (default: http://localhost:8000)

### Installation

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   # Copy the example env file
   cp .env.example .env
   
   # Edit .env and set your API base URL
   VITE_API_BASE_URL=http://localhost:8000
   ```

4. **Start the development server:**
   ```bash
   npm run dev
   ```

5. **Open in browser:**
   Navigate to http://localhost:5173

## 📋 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build production bundle |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint for code quality |

## 🔌 API Endpoints

The frontend expects these backend endpoints:

### GET /home
Returns dashboard metrics:
```json
{
  "avgFleetReadiness": 85.5,
  "criticalAlertCount": 2,
  "isSystemSynced": true,
  "fleetStressDelta": 3.2,
  "raw_aggregates": {
    "avg_pulse": 73.2,
    "avg_crc": 15.4
  }
}
```

### GET /drivers/{fullName}
Returns array of scans for a driver:
```json
[
  {
    "id": 1,
    "driver_id": "DRV001",
    "fullname": "John Doe",
    "timestamp": "2024-01-10T10:30:00Z",
    "pulse_rate": 72.5,
    "breathing_rate": 14.2,
    "pulse_respiration_quotient": 5.1,
    "integrated_vital_score": 10.3,
    "cardio_respiratory_coupler": 15.2,
    "nonlinear_alertness_index": 12.5,
    "status": "PASS",
    "risk_score": 2.0,
    "fail_reason": null
  }
]
```

## 🎨 Design System

The dashboard uses a dark theme with:
- **Primary**: Green (#22c55e) for success states
- **Destructive**: Red for warnings/errors
- **Warning**: Amber for caution states
- **Muted backgrounds** for cards and sections

### Key UI Components
- `StatCard` - KPI display cards with trends
- `ChartCard` - Wrapper for charts
- `Badge` / `StatusBadge` / `RiskBadge` - Status indicators
- `Avatar` - Driver avatar with initials
- `Tabs` - Segmented navigation
- `ProgressRing` - Circular progress indicator

## 📱 Pages

### /home
- Fleet overview dashboard
- KPI cards (Fleet Readiness, Alerts, Sync Status, Stress)
- Vital trends chart
- Driver fleet table (sortable by risk)

### /drivers/:fullName
- Driver detail view with breadcrumb navigation
- Header with avatar, status, and summary stats
- Tabbed sections:
  - **Overview**: KPIs + charts
  - **History**: Complete scan table
  - **Metrics**: Advanced derived metrics with explanations

## ⚡ Features

- ✅ Responsive design (mobile-first)
- ✅ Dark mode by default
- ✅ Skeleton loading states
- ✅ Error boundaries
- ✅ Empty states
- ✅ Smooth animations (Framer Motion)
- ✅ Type-safe API client
- ✅ React Query for caching
- ✅ Keyboard accessible

## 🐛 Troubleshooting

### API Connection Issues
- Ensure the backend is running on the URL specified in `.env`
- Check CORS settings on the backend
- Verify network connectivity

### Empty Data
- The dashboard handles empty states gracefully
- Some demo data is shown when no real data exists
- Check the backend for scan data

## 📝 TODOs

- [ ] Add search functionality
- [ ] Implement notifications
- [ ] Add date range filters for charts
- [ ] Export data functionality
- [ ] Real-time updates via WebSocket

---

Built with ❤️ for DeltaHacks 2026

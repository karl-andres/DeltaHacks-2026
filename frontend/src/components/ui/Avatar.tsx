import { getInitials } from '@/lib/utils';

interface AvatarProps {
    name: string;
    size?: 'sm' | 'md' | 'lg';
}

const sizeStyles = {
    sm: 'h-8 w-8 text-xs',
    md: 'h-10 w-10 text-sm',
    lg: 'h-12 w-12 text-base',
};

// Consistent color palette for avatars - no random generation
const colors = [
    'bg-emerald-600',
    'bg-blue-600',
    'bg-purple-600',
    'bg-amber-600',
    'bg-rose-600',
    'bg-cyan-600',
    'bg-indigo-600',
    'bg-teal-600',
];

function getColorFromName(name: string): string {
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    return colors[Math.abs(hash) % colors.length];
}

export function Avatar({ name, size = 'md' }: AvatarProps) {
    const initials = getInitials(name);
    const bgColor = getColorFromName(name);

    return (
        <div
            className={`flex items-center justify-center rounded-full font-semibold text-white ${sizeStyles[size]} ${bgColor}`}
            aria-label={name}
        >
            {initials}
        </div>
    );
}

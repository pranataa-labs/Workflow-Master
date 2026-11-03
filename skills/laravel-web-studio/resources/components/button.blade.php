@props([
    'variant' => 'primary', // primary | secondary | outline | wa | ghost | danger
    'size' => 'md',        // sm | md | lg
    'href' => null,
    'type' => 'button',
    'icon' => null,
    'iconRight' => null,
    'loading' => false,
])

@php
$baseClasses = 'inline-flex items-center justify-center font-medium transition-all duration-150 ease-out focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 active:scale-[0.98] disabled:opacity-60 disabled:pointer-events-none select-none rounded-btn';

$sizes = [
    'sm' => 'h-9 px-3.5 text-xs gap-1.5',
    'md' => 'h-11 px-5 text-sm gap-2',
    'lg' => 'h-13 px-7 text-base gap-2.5 font-semibold',
];

$variants = [
    'primary' => 'bg-brand-600 text-white hover:bg-brand-700 focus-visible:ring-brand-500 shadow-sm hover:shadow',
    'secondary' => 'bg-brand-50 text-brand-800 hover:bg-brand-100 focus-visible:ring-brand-500',
    'outline' => 'border border-ink-200 text-ink-800 bg-surface-raised hover:bg-ink-50 hover:border-ink-300 focus-visible:ring-brand-500',
    'wa' => 'bg-wa text-wa-ink hover:bg-wa-hover font-semibold focus-visible:ring-emerald-500 shadow-sm hover:shadow',
    'ghost' => 'text-ink-700 hover:bg-ink-100 hover:text-ink-950 focus-visible:ring-brand-500',
    'danger' => 'bg-danger-600 text-white hover:bg-danger-700 focus-visible:ring-danger-500',
];

$classes = "{$baseClasses} {$sizes[$size]} {$variants[$variant]}";
@endphp

@if ($href)
    <a href="{{ $href }}" {{ $attributes->merge(['class' => $classes]) }}>
        {{ $slot }}
    </a>
@else
    <button type="{{ $type }}" {{ $attributes->merge(['class' => $classes]) }}>
        {{ $slot }}
    </button>
@endif

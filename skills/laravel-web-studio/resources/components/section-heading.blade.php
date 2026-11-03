@props([
    'eyebrow' => null,
    'title',
    'subtitle' => null,
    'align' => 'left', // left | center
])

@php
    $alignClasses = $align === 'center' 
        ? 'text-center mx-auto items-center' 
        : 'text-left items-start';
@endphp

<div {{ $attributes->merge(['class' => "flex flex-col mb-8 sm:mb-12 max-w-2xl {$alignClasses}"]) }}>
    @if ($eyebrow)
        <span class="eyebrow mb-2">
            {{ $eyebrow }}
        </span>
    @endif

    <h2 class="text-3xl sm:text-4xl lg:text-5xl font-display font-bold tracking-tight text-ink-950 text-balance">
        {{ $title }}
    </h2>

    @if ($subtitle)
        <p class="mt-3 sm:mt-4 text-base sm:text-lg text-ink-600 text-pretty leading-relaxed">
            {{ $subtitle }}
        </p>
    @endif
</div>

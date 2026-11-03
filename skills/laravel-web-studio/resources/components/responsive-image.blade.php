@props([
    'path',
    'alt' => '',
    'sizes' => '(min-width: 1024px) 25vw, (min-width: 768px) 33vw, 50vw',
    'aspect' => 'aspect-square',
    'loading' => 'lazy',
    'fetchpriority' => 'auto',
    'width' => 800,
    'height' => 800,
    'class' => '',
])

@php
    // Asumsi image disederhanakan oleh ImageService dengan penamaan standar:
    // path.webp (asli/1200), path-800.webp, path-400.webp
    $extension = pathinfo($path, PATHINFO_EXTENSION);
    $basePath = preg_replace('/\.' . preg_quote($extension, '/') . '$/', '', $path);

    $src400 = "{$basePath}-400.webp";
    $src800 = "{$basePath}-800.webp";
    $src1200 = "{$basePath}.webp";

    $srcset = "{$src400} 400w, {$src800} 800w, {$src1200} 1200w";
@endphp

<div class="overflow-hidden bg-ink-100 {{ $aspect }} {{ $class }}">
    <img 
        src="{{ $src800 }}" 
        srcset="{{ $srcset }}" 
        sizes="{{ $sizes }}" 
        alt="{{ $alt }}" 
        loading="{{ $loading }}" 
        decoding="async" 
        fetchpriority="{{ $fetchpriority }}"
        width="{{ $width }}" 
        height="{{ $height }}" 
        class="h-full w-full object-cover"
    >
</div>

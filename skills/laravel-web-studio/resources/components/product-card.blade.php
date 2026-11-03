@props([
    'product',
])

@php
    $hasDiscount = !empty($product->compare_price) && $product->compare_price > $product->price;
    $isOutOfStock = $product->track_stock && $product->stock <= 0;
    $imageUrl = $product->coverImage->path ?? $product->image_path ?? asset('images/placeholder-product.webp');
    $altText = $product->coverImage->alt ?? $product->name;
@endphp

<article {{ $attributes->merge(['class' => 'group relative flex flex-col overflow-hidden rounded-card bg-surface-raised border border-ink-900/5 shadow-card transition-all duration-200 hover:-translate-y-1 hover:shadow-raised']) }}>
    {{-- Gambar & Badge --}}
    <div class="relative aspect-square w-full overflow-hidden bg-ink-100">
        <img 
            src="{{ $imageUrl }}" 
            alt="{{ $altText }}" 
            loading="lazy" 
            decoding="async"
            width="400"
            height="400"
            class="h-full w-full object-cover transition-transform duration-300 ease-out group-hover:scale-105 {{ $isOutOfStock ? 'grayscale opacity-60' : '' }}"
        >

        {{-- Badges --}}
        <div class="absolute left-3 top-3 flex flex-col gap-1.5 z-10">
            @if ($isOutOfStock)
                <span class="inline-flex items-center rounded-full bg-ink-900/80 px-2.5 py-0.5 text-xs font-semibold text-white backdrop-blur-sm">
                    Habis
                </span>
            @elseif ($product->badge === 'best_seller')
                <span class="inline-flex items-center rounded-full bg-accent-500 px-2.5 py-0.5 text-xs font-semibold text-white shadow-sm">
                    Terlaris
                </span>
            @elseif ($product->badge === 'new')
                <span class="inline-flex items-center rounded-full bg-brand-600 px-2.5 py-0.5 text-xs font-semibold text-white shadow-sm">
                    Baru
                </span>
            @endif

            @if ($hasDiscount && !$isOutOfStock)
                <span class="inline-flex items-center rounded-full bg-danger-600 px-2 py-0.5 text-[11px] font-bold text-white shadow-sm">
                    Hemat {{ round((($product->compare_price - $product->price) / $product->compare_price) * 100) }}%
                </span>
            @endif
        </div>
    </div>

    {{-- Info Produk --}}
    <div class="flex flex-1 flex-col p-4 sm:p-5">
        @if ($product->category)
            <p class="eyebrow mb-1 text-[11px] text-ink-500 font-bold uppercase tracking-wider">
                {{ $product->category->name }}
            </p>
        @endif

        <h3 class="font-display text-base sm:text-lg font-bold text-ink-950 line-clamp-2 mb-2">
            <a href="{{ route('catalog.show', $product->slug) }}" class="focus:outline-none">
                {{-- Stretched link agar seluruh kartu bisa diklik --}}
                <span class="absolute inset-0" aria-hidden="true"></span>
                {{ $product->name }}
            </a>
        </h3>

        {{-- Harga & CTA --}}
        <div class="mt-auto pt-3 flex items-center justify-between border-t border-ink-100">
            <div class="flex flex-col">
                @if ($hasDiscount)
                    <span class="text-xs text-ink-400 line-through tabular-nums">
                        {{ rupiah($product->compare_price) }}
                    </span>
                @endif
                <span class="text-base sm:text-lg font-bold text-brand-600 tabular-nums">
                    {{ rupiah($product->price) }}
                </span>
            </div>

            {{-- Tombol Aksi Tambah Cepat (Alpine Cart) --}}
            @if (!$isOutOfStock)
                <button 
                    type="button"
                    @click.stop="$store.cart.add({
                        product_id: {{ $product->id }},
                        name: '{{ addslashes($product->name) }}',
                        price: {{ $product->price }},
                        image: '{{ $imageUrl }}'
                    })"
                    aria-label="Tambah {{ $product->name }} ke keranjang"
                    class="relative z-10 flex h-9 w-9 items-center justify-center rounded-full bg-brand-50 text-brand-700 transition hover:bg-brand-600 hover:text-white focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500"
                >
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                    </svg>
                </button>
            @endif
        </div>
    </div>
</article>

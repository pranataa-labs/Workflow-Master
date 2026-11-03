<?php

namespace App\Services;

use App\Models\Order;

class WhatsAppService
{
    /**
     * Normalisasi nomor telepon lokal / internasional ke format standar WhatsApp (E.164 tanpa tanda plus).
     * Contoh: 0812-3456-7890 / +62 812-3456-7890 -> 6281234567890
     */
    public function normalizePhone(?string $phone): string
    {
        if (blank($phone)) {
            return '';
        }

        // Hapus karakter non-digit
        $digits = preg_replace('/\D/', '', $phone);

        // Jika diawali 0, ganti dengan 62
        if (str_starts_with($digits, '0')) {
            $digits = '62' . substr($digits, 1);
        }

        return $digits;
    }

    /**
     * Membangun deep-link wa.me dengan URL encoded message.
     */
    public function link(string $phone, string $message): string
    {
        $normalized = $this->normalizePhone($phone);
        // Penting: gunakan rawurlencode (RFC 3986) agar spasi menjadi %20 dan baris baru %0A, bukan tanda plus (+)
        return "https://wa.me/{$normalized}?text=" . rawurlencode($message);
    }

    /**
     * Menghasilkan teks order terformat rapi untuk dikirimkan ke WhatsApp admin.
     */
    public function orderMessage(Order $order): string
    {
        $storeName = setting('store_name', 'Toko Kami');
        $lines = [];

        $lines[] = "Halo *{$storeName}*, saya ingin konfirmasi pesanan:";
        $lines[] = "";
        $lines[] = "*Kode Order:* `{$order->code}`";
        $lines[] = "--------------------------------";

        $i = 1;
        foreach ($order->items as $item) {
            $variant = $item->variant_name ? " ({$item->variant_name})" : "";
            $subtotalFormatted = rupiah($item->subtotal);
            $lines[] = "{$i}. *{$item->product_name}*{$variant} x{$item->quantity} = {$subtotalFormatted}";
            if (!empty($item->note)) {
                $lines[] = "   _Catatan:_ \"{$item->note}\"";
            }
            $i++;
        }

        $lines[] = "--------------------------------";
        $lines[] = "*Total Belanja:* *" . rupiah($order->total) . "*";
        $lines[] = "_*Catatan:* Ongkir & instruksi transfer dikonfirmasi oleh admin._";
        $lines[] = "";
        $lines[] = "*Data Pemesan:*";
        $lines[] = "• Nama: {$order->customer_name}";
        $lines[] = "• No. WA: {$order->customer_phone}";
        $lines[] = "• Pengiriman: " . ($order->delivery_method === 'delivery' ? 'Diantar (Delivery)' : 'Ambil di Toko (Pickup)');

        if ($order->delivery_method === 'delivery' && !empty($order->address)) {
            $lines[] = "• Alamat: {$order->address}";
        }

        if ($order->scheduled_at) {
            $lines[] = "• Jadwal: " . $order->scheduled_at->translatedFormat('l, d M Y - H:i') . " WIB";
        }

        if (!empty($order->note)) {
            $lines[] = "• Catatan Khusus: {$order->note}";
        }

        $lines[] = "";
        $lines[] = "Mohon dicek dan diinfokan total transfer serta nomor rekeningnya. Terima kasih!";

        return implode("\n", $lines);
    }

    /**
     * Shortcut untuk link tanya admin umum
     */
    public function adminLink(?string $customText = null): string
    {
        $adminPhone = setting('whatsapp_number', '081234567890');
        $text = $customText ?? "Halo " . setting('store_name', 'Admin') . ", saya ingin bertanya tentang produk Anda.";
        return $this->link($adminPhone, $text);
    }
}

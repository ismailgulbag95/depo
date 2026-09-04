"""
Asset Refinement, Defringing & Hole-Filling Tool (Görsel İyileştirme ve Onarma)
------------------------------------------------------------------------------
Bu script:
1. [DELİK DOLDURMA]: Nesnenin iç kısmında yanlışlıkla silinen (metal parıltısı, beyazlık vb.)
   delikleri dış arka plandan izole ederek tespit eder ve %100 opaklıkta geri yükler.
2. [BEYAZ HALE TEMİZLEME (DEFRINGE)]: Eşyaların dış kenarında kalan stüdyo beyazı
   kalıntılarını ve beyaz pikselleri 1-2 piksel içeri çekerek (Alpha Erode) temizler.
3. [RENK TAŞMASI (COLOR BLEED)]: Kenardaki soluk pikselleri içteki gerçek doku rengiyle doyurur.
4. [KENAR YUMUŞATMA (SMOOTH)]: Kenarları ipek gibi pürüzsüz (anti-aliased) hale getirir.
"""

import os
from pathlib import Path
from PIL import Image, ImageFilter
from run_pipeline import clean_enclosed_holes

ITEMS_DIR = Path(__file__).resolve().parent.parent / "assets" / "items"

def fill_internal_holes(alpha_channel):
    """
    Nesnenin İÇİNDE kalmış olan delikleri doldurur.
    Mantık: Dış kenarlardan (0,0) Flood-Fill ile sadece gerçek dış arka plan bulunur.
    Dışarıyla bağlantısı olmayan tüm şeffaf pikseller 'iç delik'tir ve doldurulur.
    """
    w, h = alpha_channel.size
    
    # 1. Aşama: Dış boşluğu tespit et (0 = dış zemin, 255 = nesne veya iç delik)
    # Eşik: alfa < 40 olanlar potansiyel boşluktur
    bin_alpha = alpha_channel.point(lambda p: 0 if p < 40 else 255)
    
    # 4 kenardan başlayarak dış boşluğu Flood-Fill yap
    # Dış boşluk = 128 ile işaretlenir
    fill_mask = bin_alpha.copy()
    
    # BFS ile dış sınırları sula
    pixels = fill_mask.load()
    visited = bytearray(w * h)
    queue = []

    # 4 kenar pikselleri tohum (seed) olarak ekle
    for x in range(w):
        if pixels[x, 0] == 0:
            queue.append((x, 0))
            visited[x] = 1
        if pixels[x, h - 1] == 0:
            queue.append((x, h - 1))
            visited[(h - 1) * w + x] = 1

    for y in range(h):
        if pixels[0, y] == 0:
            queue.append((0, y))
            visited[y * w] = 1
        if pixels[w - 1, y] == 0:
            queue.append((w - 1, y))
            visited[y * w + (w - 1)] = 1

    q_idx = 0
    while q_idx < len(queue):
        cx, cy = queue[q_idx]
        q_idx += 1

        for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if 0 <= nx < w and 0 <= ny < h:
                pos = ny * w + nx
                if not visited[pos]:
                    visited[pos] = 1
                    if pixels[nx, ny] == 0:
                        queue.append((nx, ny))

    # visited[pos] == 1 olanlar KESİN DIŞ ARKA PLANDIR.
    # visited[pos] == 0 olup bin_alpha'sı 0 olanlar ise iç boşluklardır.
    # [KRİTİK KURAL]: Yayın ortası, arbalet kirişi, kulp gibi BÜYÜK DOĞAL BOŞLUKLAR (alan > 250 px)
    # kesinlikle doldurulmaz, ŞEFFAF BIRAKILIR! Sadece küçük pürüz/parıltı delikleri onarılır.
    
    # İç boşluk adacıklarını etiketle
    hole_visited = bytearray(w * h)
    small_holes = set()

    for y in range(h):
        for x in range(w):
            pos = y * w + x
            if not visited[pos] and pixels[x, y] == 0 and not hole_visited[pos]:
                # Yeni iç delik adacığı
                hole_q = [(x, y)]
                hole_visited[pos] = 1
                q_i = 0
                while q_i < len(hole_q):
                    hx, hy = hole_q[q_i]
                    q_i += 1
                    for d_x, d_y in ((hx+1, hy), (hx-1, hy), (hx, hy+1), (hx, hy-1)):
                        if 0 <= d_x < w and 0 <= d_y < h:
                            d_pos = d_y * w + d_x
                            if not visited[d_pos] and pixels[d_x, d_y] == 0 and not hole_visited[d_pos]:
                                hole_visited[d_pos] = 1
                                hole_q.append((d_x, d_y))

                # Eğer delik küçük bir pürüz ise (örneğin < 250 piksel metal parıltı deliği)
                if len(hole_q) < 250:
                    for px, py in hole_q:
                        small_holes.add((px, py))

    new_alpha = Image.new("L", (w, h), 0)
    new_pixels = new_alpha.load()
    orig_alpha_pixels = alpha_channel.load()

    for y in range(h):
        for x in range(w):
            if (x, y) in small_holes:
                # Küçük metalik parıltı deliği -> Opak yap
                new_pixels[x, y] = 255
            else:
                # Doğal boşluk (yayın ortası gibi) veya dış arka plan -> Orijinal şeffaflığı koru
                new_pixels[x, y] = orig_alpha_pixels[x, y]

    return new_alpha

def remove_white_fringe(rgba_img, erode_radius=1):
    """
    Kenarlarda kalan beyaz haleleri (white halo) yok eder:
    1. Alfa kanalını 1 piksel aşındırır (MinFilter).
    2. Kenar piksellerindeki beyaz/açık renk sızıntısını temizler.
    3. Kenarları yumuşatır.
    """
    w, h = rgba_img.size
    r, g, b, a = rgba_img.split()

    # 1. Delik onarımı yap
    filled_a = fill_internal_holes(a)

    # 2. Alfa kanalını 1-2 piksel içeri çek (Erosion) - beyaz dış kenarı kes
    if erode_radius > 0:
        # MinFilter(3) = 1 piksel içeri çekme
        eroded_a = filled_a.filter(ImageFilter.MinFilter(3))
    else:
        eroded_a = filled_a

    # 3. Kenar piksellerinde kalan beyaz tonları nötralize et (Defringe Color Bleed)
    # Eğer bir pikselin alfası düşük ve rengi çok açıksa (R,G,B > 220), onu saydam yap
    clean_r = r.copy()
    clean_g = g.copy()
    clean_b = b.copy()
    final_a = eroded_a.copy()

    pix_r = clean_r.load()
    pix_g = clean_g.load()
    pix_b = clean_b.load()
    pix_a = final_a.load()

    for y in range(h):
        for x in range(w):
            alpha_val = pix_a[x, y]
            if 0 < alpha_val < 220:
                # Kenar bölgesindeyiz
                red_val = pix_r[x, y]
                green_val = pix_g[x, y]
                blue_val = pix_b[x, y]
                # Beyaz veya açık gri kalıntı ise alfayı kıs
                if red_val > 210 and green_val > 210 and blue_val > 210:
                    pix_a[x, y] = 0

    # 4. Kenarları yumuşat (Anti-aliasing)
    smooth_a = final_a.filter(ImageFilter.SMOOTH)

    return Image.merge("RGBA", (clean_r, clean_g, clean_b, smooth_a))

def process_item_file(image_path):
    """Tek bir PNG dosyasını okuyup kusursuzlaştırır ve hem PNG hem WebP olarak günceller."""
    img = Image.open(image_path).convert("RGBA")
    
    # 1. Kapalı halka ve delik boşluklarını (tefin ortası, anahtar deliği) temizle
    img = clean_enclosed_holes(img)
    
    # 2. Dış kenar beyaz halelerini temizle
    refined_img = remove_white_fringe(img, erode_radius=1)

    # Orijinal dosyaların üzerine kaydet
    refined_img.save(image_path, "PNG")
    
    webp_path = Path(image_path).with_suffix(".webp")
    refined_img.save(webp_path, "WEBP", quality=95, lossless=True)

def main():
    if not ITEMS_DIR.exists():
        print(f"[!] '{ITEMS_DIR}' klasörü bulunamadı.")
        return

    png_files = sorted(list(ITEMS_DIR.glob("**/*.png")))
    total = len(png_files)
    print("================================================================")
    print(f"GÖRSEL İYİLEŞTİRME VE KENAR TEMİZLEME (DEFRINGE) BAŞLADI")
    print(f"Toplam İşlenecek Eşya Sayısı: {total}")
    print("================================================================")

    for idx, f in enumerate(png_files, 1):
        rel_path = f.relative_to(ITEMS_DIR)
        process_item_file(str(f))
        if idx % 10 == 0 or idx == total:
            print(f"  [{idx:03d}/{total}] Onarıldı & Temizlendi: {rel_path}")

    print("================================================================")
    print("TÜM EŞYALAR BAŞARIYLA ONARILDI!")
    print("  ✓ İç delikler kapatıldı (cismin üzerindeki silinen bölgeler geri getirildi)")
    print("  ✓ Dış kenarlardaki beyaz haleler (fringing) tamamen temizlendi")
    print("  ✓ Kenarlar pürüzsüz (anti-aliased) hale getirildi")
    print("================================================================")

if __name__ == "__main__":
    main()

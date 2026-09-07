import os
import sys
import time
import urllib.parse
import requests

# Kaydedilecek hedef dizin
OUTPUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "ui"))

# Şehir Haritası İkonları - Pollinations AI (Flux) Promptları
# Stil: Modern mobil navigasyon ve RPG diegetik harita rozetleri, şık neon & metalik detaylar, siyah/saydam zemin, app icon / badge tarzı
MAP_ICON_PROMPTS = {
    "icon_map_home": {
        "title": "Ev & Karargah İkonu",
        "filename": "icon_map_home.png",
        "prompt": "Game UI icon emblem, stylized modern headquarters mansion with glowing cyan neon accents, futuristic home workshop base, isometric isometric badge, dark background, 3d render style, vibrant game asset, high contrast, clean vector edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_wholesaler": {
        "title": "Toptancı & Hurdalık İkonu",
        "filename": "icon_map_wholesaler.png",
        "prompt": "Game UI icon emblem, industrial metal scrap crane and cargo container, glowing amber orange neon warning stripes, recycling junkyard warehouse symbol, dark background, 3d render game badge, high contrast, clean edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_dealership": {
        "title": "Oto Sanayi İkonu",
        "filename": "icon_map_dealership.png",
        "prompt": "Game UI icon emblem, mechanic auto garage wrench and rugged pickup truck silhouette, glowing steel blue neon rim lighting, automotive tuning badge, dark background, 3d render, high contrast, clean edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_pawn": {
        "title": "Rehin Dükkanı İkonu",
        "filename": "icon_map_pawn.png",
        "prompt": "Game UI icon emblem, antique golden balance scales with gleaming emerald green gemstone and gold coins, vintage pawn shop curio symbol, dark background, 3d render, high contrast, clean edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_auction": {
        "title": "Canlı Depo Mezatı İkonu",
        "filename": "icon_map_auction.png",
        "prompt": "Game UI icon emblem, heavy wooden auctioneer gavel slamming down on storage garage roll-up door, glowing crimson red neon sparks, auction arena badge, dark background, dramatic 3d render, high contrast, clean edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_real_estate": {
        "title": "Emlak Bürosu İkonu",
        "filename": "icon_map_real_estate.png",
        "prompt": "Game UI icon emblem, modern corporate glass skyscraper tower with golden architectural blueprint key, glowing yellow gold neon accents, real estate tycoon badge, dark background, 3d render, clean edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_tavern": {
        "title": "Kara Ejder Hanı İkonu",
        "filename": "icon_map_tavern.png",
        "prompt": "Game UI icon emblem, medieval wooden tavern beer stein with foaming ale and carved dragon motif, glowing purple violet amber lantern light, mercenary tavern badge, dark background, 3d render, clean edges, 512x512",
        "width": 512,
        "height": 512
    },
    "icon_map_dungeon": {
        "title": "Zindan & Seferler İkonu",
        "filename": "icon_map_dungeon.png",
        "prompt": "Game UI icon emblem, dark fantasy stone fortress gate with crossed iron swords and mystical glowing crimson portal eye, dungeon raid shield badge, dark background, 3d render, clean edges, 512x512",
        "width": 512,
        "height": 512
    }
}

def generate_and_download_icon(item_key, data):
    filename = data["filename"]
    prompt = data["prompt"]
    width = data.get("width", 512)
    height = data.get("height", 512)
    title = data.get("title", item_key)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    target_path = os.path.join(OUTPUT_DIR, filename)

    print(f"\n==========================================")
    print(f"🗺️ Üretiliyor: {title} -> {filename}")
    
    encoded_prompt = urllib.parse.quote(prompt)
    url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width={width}&height={height}&nologo=true&model=flux"

    try:
        start_time = time.time()
        print(f"⏳ Pollinations AI (Flux) üzerinden indiriliyor...")
        response = requests.get(url, timeout=75)
        
        if response.status_code == 200:
            with open(target_path, "wb") as f:
                f.write(response.content)
            duration = round(time.time() - start_time, 2)
            file_size_kb = round(os.path.getsize(target_path) / 1024, 1)
            print(f"✅ Başarıyla kaydedildi: {target_path} ({file_size_kb} KB, {duration}s)")
            return True
        else:
            print(f"❌ Sunucu Hatası ({response.status_code}): {response.text[:100]}")
            return False
    except Exception as e:
        print(f"❌ İndirme sırasında hata: {e}")
        return False

def main():
    print("🚀 DEPO AVCILARI - Harita Navigasyon İkonları Üretim Aracı (Pollinations Flux)")
    print(f"📁 Hedef Klasör: {OUTPUT_DIR}")
    
    success_count = 0
    total = len(MAP_ICON_PROMPTS)

    for key, data in MAP_ICON_PROMPTS.items():
        if generate_and_download_icon(key, data):
            success_count += 1
        time.sleep(1) # Rate limit nezaket beklemesi

    print("\n" + "=" * 50)
    print(f"🎉 Tamamlandı! {success_count}/{total} harita ikonu başarıyla oluşturuldu.")
    return success_count == total

if __name__ == "__main__":
    main()

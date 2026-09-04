import os
import time
import urllib.parse
import requests

# Kaydedilecek hedef dizin
OUTPUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "vehicles"))

# Depo Avcıları Oyun Konseptine Uygun Bagaj Promptları
TRUNK_PROMPTS = {
    "pickup_truck_bed": {
        "title": "Standart Pikap Kasası",
        "filename": "pickup_truck_bed.png",
        "prompt": "Top-down orthographic view of an empty rugged pickup truck cargo bed, industrial diamond plate metal floor, realistic metallic texture, warehouse storage raiders style, heavy duty steel rails, dramatic studio lighting, soft shadow, clean game asset background, 8k resolution, photorealistic",
        "width": 1024,
        "height": 1024
    },
    "cargo_van_interior": {
        "title": "Panelvan / Kamyonet İçi",
        "filename": "cargo_van_interior.png",
        "prompt": "Top-down direct orthographic view inside empty cargo van storage compartment, ribbed steel floor, metal walls, industrial rivets, ambient garage lighting, realistic textures, clean grid asset, photorealistic, 8k",
        "width": 1024,
        "height": 1024
    },
    "heavy_transport_flatbed": {
        "title": "Ağır Nakliye Kasası (Büyük Araç)",
        "filename": "heavy_transport_flatbed.png",
        "prompt": "Top-down overhead view of heavy duty flatbed industrial truck bed, dark steel plates with yellow caution stripes on borders, clean textured surface, warehouse equipment, cinematic rim lighting, 8k resolution",
        "width": 1024,
        "height": 1024
    },
    "metal_trunk_diegetic_panel": {
        "title": "Diegetic Metal Bagaj Izgarası Arka Planı",
        "filename": "metal_trunk_diegetic_panel.png",
        "prompt": "Top-down seamless industrial metal panel texture, diamond plate steel surface, dark gunmetal finish, bolts and rivets on borders, dramatic studio spotlight, high detail, 4k",
        "width": 1024,
        "height": 1024
    }
}

def generate_and_download_image(item_key, data):
    filename = data["filename"]
    prompt = data["prompt"]
    width = data.get("width", 1024)
    height = data.get("height", 1024)
    title = data.get("title", item_key)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    target_path = os.path.join(OUTPUT_DIR, filename)

    print(f"\n==========================================")
    print(f"📦 Üretiliyor: {title} ({filename})")
    print(f"🎨 Prompt: {prompt[:80]}...")
    
    encoded_prompt = urllib.parse.quote(prompt)
    # Pollinations AI Endpoint (nologo ve yüksek kalite parametreleri)
    url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width={width}&height={height}&nologo=true&model=flux"

    try:
        start_time = time.time()
        print(f"⏳ Pollinations AI'dan indiriliyor: {url}")
        response = requests.get(url, timeout=60)
        
        if response.status_code == 200:
            with open(target_path, "wb") as f:
                f.write(response.content)
            duration = round(time.time() - start_time, 2)
            file_size_kb = round(os.path.getsize(target_path) / 1024, 1)
            print(f"✅ Başarıyla kaydedildi: {target_path} ({file_size_kb} KB, {duration}s)")
            return True
        else:
            print(f"❌ Sunucu Hatası: {response.status_code} - {response.text[:100]}")
            return False
    except Exception as e:
        print(f"❌ İndirme sırasında hata: {e}")
        return False

def main():
    print("🚀 DEPO AVCILARI - Araç Bagajı Görsel Üretim Aracı (Pollinations AI)")
    print(f"📁 Hedef Klasör: {OUTPUT_DIR}")
    
    success_count = 0
    total = len(TRUNK_PROMPTS)

    for key, data in TRUNK_PROMPTS.items():
        if generate_and_download_image(key, data):
            success_count += 1
        time.sleep(1) # API nezaket beklemesi

    print("\n" + "=" * 50)
    print(f"🎉 Tamamlandı! {success_count}/{total} görsel başarıyla oluşturuldu ve kaydedildi.")

if __name__ == "__main__":
    main()

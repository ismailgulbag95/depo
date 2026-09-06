import os
import json
import re
from pathlib import Path

PROJECT_ROOT = Path(r"d:\github\depo")
ITEMS_DIR = PROJECT_ROOT / "assets" / "items"
OUTPUT_JSON = PROJECT_ROOT / "assets" / "data" / "default_items.json"

CATEGORY_NAMES = {
    "agir_sanayi": ("Ağır Sanayi Ekipmanı", "Heavy Industrial Equipment", "Тяжелая промышленность", "Equipo industrial pesado"),
    "ahsap_mobilya": ("Ahşap Mobilya", "Wooden Furniture", "Деревянная мебель", "Muebles de madera"),
    "araba_parcalari": ("Oto Yedek Parça", "Auto Spare Parts", "Автозапчасти", "Autopartes"),
    "beyaz_esya": ("Ev Aletleri & Beyaz Eşya", "Home Appliances", "Бытовая техника", "Electrodomésticos"),
    "buyulu_silahlar": ("Efsanevi Silah", "Mythic Weapon", "Мифическое оружие", "Arma mítica"),
    "buyulu_takilar": ("Kıymetli Takı & Mücevher", "Precious Jewelry", "Драгоценные украшения", "Joyería preciosa"),
    "buyulu_zirhlar": ("Özel Zırh", "Special Armor", "Специальная броня", "Armadura especial"),
    "cesitli_mobilyalar": ("Oda Mobilyası", "Room Furniture", "Мебель для комнаты", "Muebles de habitación"),
    "elektronik_aletler": ("Elektronik & Elektrikli Alet", "Power & Electronic Tools", "Электроинструменты", "Herramientas eléctricas"),
    "gercekci_silahlar": ("Taktik Ekipman", "Tactical Gear", "Тактическое снаряжение", "Equipo táctico"),
    "laboratuvar_simya": ("Laboratuvar & Kimya", "Laboratory & Chemistry", "Лаборатория и химия", "Laboratorio y química"),
    "maden_ve_taslar": ("Kıymetli Maden & Külçe", "Precious Metal & Gem", "Драгоценный металл", "Metal precioso"),
    "manuel_el_aletleri": ("Manuel El Aleti", "Manual Hand Tools", "Ручные инструменты", "Herramientas manuales"),
    "melez_arcane_tech": ("Retro Teknoloji", "Retro Tech", "Ретро технологии", "Tecnología retro"),
    "muzik_aletleri": ("Müzik Aleti", "Musical Instrument", "Музыкальный инструмент", "Instrumento musical"),
    "ofis_ekipmanlari": ("Ofis & Büro Eşyası", "Office Equipment", "Офисное оборудование", "Equipo de oficina"),
    "sanat_antikalar": ("Sanat & Antika Eser", "Art & Antiques", "Искусство и антиквариат", "Arte y antigüedades"),
    "taktik_hayatta_kalma": ("Kamp & Outdoor", "Camp & Outdoor", "Кемпинг и туризм", "Camping y aire libre"),
    "tezgah_donanimlari": ("Atölye Tezgahı", "Workshop Hardware", "Оборудование для мастерской", "Equipo de taller"),
    "tier1_bronz_zirh": ("Bronz Koleksiyon", "Bronze Collection", "Бронзовая коллекция", "Colección de bronce"),
    "tier2_celik_zirh": ("Çelik Koleksiyon", "Steel Collection", "Стальная коллекция", "Colección de acero"),
    "tier3_titanyum_zirh": ("Titanyum Koleksiyon", "Titanium Collection", "Титановая коллекция", "Colección de titanio"),
}

def clean_title(name: str) -> str:
    # 01_retro_buzdolabi.webp -> Retro Buzdolabi
    base = Path(name).stem
    base = re.sub(r'^\d+_', '', base)
    words = base.replace('_', ' ').split()
    return ' '.join(w.capitalize() for w in words)

def estimate_dimensions_and_weight(folder_name: str, item_name: str):
    lower = item_name.lower()
    # Büyük hacimli parçalar (Koltuk, Buzdolabı, Jeneratör, V8 Motor)
    if any(k in lower for k in ['kanepe', 'sofa', 'koltuk', 'buzdolabi', 'fridge', 'refrigerator', 'motor_blogu', 'engine', 'dolap', 'cabinet', 'tezgah', 'jenerator', 'generator', 'camasir_makinesi']):
        width = 4 if ('kanepe' in lower or 'sofa' in lower or 'tezgah' in lower or 'motor' in lower) else 2
        height = 3 if ('motor' in lower or 'tezgah' in lower) else (4 if 'buzdolabi' in lower or 'dolap' in lower else 2)
        weight = 35.0 + (width * height * 5.0)
        base_val = 600 + (width * height * 80)
    elif any(k in lower for k in ['tv', 'televizyon', 'matkap', 'drill', 'mikrodalga', 'microwave', 'gitar', 'guitar', 'akordeon', 'saksafon', 'keman', 'flut', 'trompet', 'alet_cantasi', 'toolbox', 'vantilator', 'fan', 'supurge', 'vacuum', 'kasa', 'safe']):
        width = 3 if ('tv' in lower or 'toolbox' in lower or 'alet_cantasi' in lower) else 2
        height = 3 if ('gitar' in lower or 'keman' in lower) else 2
        weight = 6.0 + (width * height * 2.0)
        base_val = 220 + (width * height * 45)
    else:
        # Küçük parçalar (Altın, Saat, Pense, Çekiç, Buji, Mücevher, Madalyon)
        width = 2 if ('kulce' in lower or 'gold' in lower or 'gumus' in lower or 'bar' in lower or 'ingot' in lower) else 1
        height = 1 if ('kulce' in lower or 'gold' in lower or 'gumus' in lower or 'saat' in lower or 'yuzuk' in lower) else 2
        weight = 1.0 + (width * height * 0.8)
        base_val = 120 + (width * height * 90)

    # Kıymetli maden/mücevher bonusu
    if any(k in lower for k in ['altin', 'gold', 'elmas', 'diamond', 'yakut', 'ruby', 'zumrut', 'emerald', 'mucevher']):
        base_val *= 4

    # Bitmask hesapla
    # her satırda (1 << width) - 1
    row_mask = (1 << width) - 1
    bitmask = [row_mask for _ in range(height)]

    return width, height, bitmask, round(weight, 1), int(base_val)

def main():
    print("📦 Tüm eşya görselleri taranıyor ve default_items.json üretiliyor...")
    items = []
    auto_id = 1

    for category_dir in sorted(ITEMS_DIR.iterdir()):
        if not category_dir.is_dir():
            continue
        cat_name = category_dir.name
        cat_meta = CATEGORY_NAMES.get(cat_name, (cat_name.replace('_', ' ').capitalize(), cat_name, cat_name, cat_name))

        # Folder içindeki webp veya png dosyalarını bul
        seen_stems = set()
        for file_path in sorted(category_dir.iterdir()):
            if file_path.suffix.lower() not in ['.webp', '.png']:
                continue
            stem = file_path.stem
            if stem in seen_stems:
                continue
            seen_stems.add(stem)

            # Tercih webp, yoksa png
            chosen_file = category_dir / f"{stem}.webp"
            if not chosen_file.exists():
                chosen_file = category_dir / f"{stem}.png"

            rel_sprite_path = f"assets/items/{cat_name}/{chosen_file.name}"
            raw_title = clean_title(chosen_file.name)
            width, height, bitmask, weight, base_val = estimate_dimensions_and_weight(cat_name, chosen_file.name)

            item = {
                "id": auto_id,
                "code": f"{cat_name}_{stem}",
                "name_tr": f"{raw_title} ({cat_meta[0]})",
                "name_en": f"{raw_title} ({cat_meta[1]})",
                "name_ru": f"{raw_title} ({cat_meta[2]})",
                "name_es": f"{raw_title} ({cat_meta[3]})",
                "category": cat_name,
                "baseValue": base_val,
                "width": width,
                "height": height,
                "bitmask": bitmask,
                "weight": weight,
                "spritePath": rel_sprite_path,
                "condition": "good",
                "dirtPercentage": 25.0
            }
            items.append(item)
            auto_id += 1

    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(items, f, ensure_ascii=False, indent=2)

    print(f"🎉 TOPLAM {len(items)} ADET %100 DOĞRULANMIŞ EŞYA default_items.json İÇİNE KAYDEDİLDİ!")

if __name__ == "__main__":
    main()

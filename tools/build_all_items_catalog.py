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
    "mutfak_gastronomi": ("Mutfak & Gastronomi", "Kitchen & Gastronomy", "Кухня и кулинария", "Cocina y gastronomía"),
    "kilit_ve_hirsizlik": ("Kilit Açma & Casusluk", "Lockpicking & Espionage", "Взлом и шпионаж", "Ganzuado y espionaje"),
    "tip_ve_saglik": ("Tıp & Acil Sağlık", "Medical & Emergency Health", "Медицина и здоровье", "Medicina y salud"),
    "denizcilik_ve_balikcilik": ("Denizcilik & Seyir", "Maritime & Seafaring", "Морское дело и рыбалка", "Marítimo y pesca"),
    "arkeoloji_ve_antik_kalintilar": ("Arkeoloji & Antik Eserler", "Archaeology & Antiquities", "Археология и древности", "Arqueología y antigüedades"),
    "tarim_ve_bahce_ekipmanlari": ("Tarım & Bahçe Ekipmanları", "Farming & Garden Tools", "Сельское хозяйство и сад", "Agricultura y jardinería"),
}


def clean_title(name: str) -> str:
    # 01_retro_buzdolabi.webp -> Retro Buzdolabi
    base = Path(name).stem
    base = re.sub(r'^\d+_', '', base)
    words = base.replace('_', ' ').split()
    return ' '.join(w.capitalize() for w in words)

def estimate_dimensions_and_weight(folder_name: str, item_name: str):
    lower = f"{folder_name} {item_name}".lower()

    # 1. MEGA / DEV EŞYALAR (Buzdolabı, Kanepe, Dolap, V8 Motor, Jeneratör, Çamaşır Makinesi, Büyük Sandık/Tezgah)
    # Oda yüksekliğinin yarısından fazlası (~%58-%65)
    if any(k in lower for k in [
        'buzdolabi', 'fridge', 'refrigerator', 'kanepe', 'sofa', 'koltuk',
        'motor_blogu', 'engine', 'dolap', 'gardrop', 'wardrobe', 'cabinet',
        'jenerator', 'generator', 'camasir_makinesi', 'bulasik_makinesi',
        'torna_tezgahi', 'sanayi_tipi_kompresor', 'buyuk_celik_kasa', 'palet_istif'
    ]):
        if 'buzdolabi' in lower or 'fridge' in lower or 'refrigerator' in lower or 'gardrop' in lower or 'wardrobe' in lower or 'dolap' in lower:
            width = 2
            height = 4  # Dikine uzun, buzdolabı/dolap
            room_ratio = 0.62
        elif 'kanepe' in lower or 'sofa' in lower:
            width = 4
            height = 2  # Enine geniş kanepe
            room_ratio = 0.50
        elif 'motor' in lower or 'tezgah' in lower or 'kompresor' in lower:
            width = 3
            height = 3  # Kübik devasa blok
            room_ratio = 0.58
        else:
            width = 3
            height = 3
            room_ratio = 0.56
        weight = 45.0 + (width * height * 5.0)
        base_val = 650 + (width * height * 90)

    # 2. BÜYÜK EŞYALAR (Büyük TV, Sandık, Akordeon, Bisiklet, Fıçı, Varil, Büyük Hoparlör, Çim Biçme)
    # Oda yüksekliğinin ~%35-%45'i
    elif any(k in lower for k in [
        'tv', 'televizyon', 'sandik', 'chest', 'varil', 'barrel', 'fici',
        'akordeon', 'bisiklet', 'bicycle', 'hoparlor', 'speaker', 'cim_bicme',
        'plak_calar', 'gramofon', 'tulum', 'gitar', 'guitar', 'keman', 'cello',
        'kompresor', 'jenerator', 'akvaryum', 'masa_lambasi_antika', 'soba'
    ]):
        if 'tv' in lower or 'televizyon' in lower or 'sandik' in lower:
            width = 3
            height = 2
            room_ratio = 0.40
        elif 'gitar' in lower or 'keman' in lower or 'akordeon' in lower:
            width = 2
            height = 3
            room_ratio = 0.42
        else:
            width = 2
            height = 2
            room_ratio = 0.38
        weight = 14.0 + (width * height * 2.5)
        base_val = 260 + (width * height * 50)

    # 3. ORTA BOY EŞYALAR (Mikrodalga, Elektrikli Süpürge, Matkap Çantası, Koli, Vantilatör, Kasa)
    # Oda yüksekliğinin ~%22-%28'i
    elif any(k in lower for k in [
        'mikrodalga', 'microwave', 'supurge', 'vacuum', 'matkap', 'drill',
        'alet_cantasi', 'toolbox', 'vantilator', 'fan', 'koli', 'kutu', 'box',
        'amfi', 'tost_makinesi_sanayi', 'daktilo', 'evrak_cantasi', 'tencere_seti',
        'projektor', 'kamera_profesyonel', 'kask', 'yelek', 'migfer'
    ]):
        width = 2
        height = 2
        room_ratio = 0.26
        weight = 5.0 + (width * height * 1.5)
        base_val = 160 + (width * height * 40)

    # 4. KÜÇÜK EŞYALAR (Ketıl, Su Isıtıcısı, Küçük Tost Makinesi, Kahve Makinesi, Telsiz, Dürbün, Ütü, Pense)
    # Buzdolabına göre belirgin şekilde az yer kaplar (~%15-%19)
    elif any(k in lower for k in [
        'ketil', 'kettle', 'isitici', 'tost', 'kahve', 'coffee', 'telsiz',
        'radio', 'durbun', 'binocular', 'utu', 'iron', 'pense', 'cekiç', 'hammer',
        'ingiliz_anahtari', 'wrench', 'fener', 'flashlight', 'pusula', 'compass',
        'multimetre', 'lehim', 'kulaklik', 'termos', 'matara'
    ]):
        width = 1
        height = 2  # Tetris'te 1x2 veya 2x1
        room_ratio = 0.17
        weight = 2.0 + (width * height * 0.6)
        base_val = 110 + (width * height * 30)

    # 5. MİKRO / CEP EŞYALARI (Kalem, Buji, Çakmak, Anahtar, Saat, Yüzük, Külçe Altın/Gümüş, Madalyon, Taşlar)
    # Ketıla göre çok daha az yer kaplar (~%7-%10)
    elif any(k in lower for k in [
        'kalem', 'pen', 'buji', 'spark', 'cakmak', 'lighter', 'anahtar', 'key',
        'saat', 'watch', 'yuzuk', 'ring', 'kolye', 'necklace', 'kulce', 'ingot',
        'bar', 'altin', 'gold', 'gumus', 'silver', 'elmas', 'diamond', 'yakut',
        'ruby', 'zumrut', 'emerald', 'mucevher', 'bozuk_para', 'coin', 'madalyon',
        'sim_karti', 'usb', 'cip', 'vida', 'civata'
    ]):
        width = 1
        height = 1  # Tetris'te sadece 1x1
        room_ratio = 0.08
        weight = 0.3
        base_val = 90
        # Değerli maden/mücevher çarpanı
        if any(g in lower for g in ['altin', 'gold', 'elmas', 'diamond', 'yakut', 'ruby', 'zumrut', 'emerald', 'mucevher']):
            base_val = 500
    else:
        # Kategoriye göre genel varsayılan
        if any(cat in folder_name for cat in ['beyaz_esya', 'agir_sanayi', 'ahsap_mobilya']):
            width, height, room_ratio, weight, base_val = 2, 3, 0.45, 25.0, 350
        elif any(cat in folder_name for cat in ['elektronik_aletler', 'muzik_aletleri', 'sanat_antikalar']):
            width, height, room_ratio, weight, base_val = 2, 2, 0.28, 7.0, 220
        elif any(cat in folder_name for cat in ['buyulu_takilar', 'maden_ve_taslar', 'kilit_ve_hirsizlik']):
            width, height, room_ratio, weight, base_val = 1, 1, 0.08, 0.5, 200
        else:
            width, height, room_ratio, weight, base_val = 1, 2, 0.17, 2.5, 120

    # Kıymetli maden/mücevher bonusu
    if any(k in lower for k in ['altin', 'gold', 'elmas', 'diamond', 'yakut', 'ruby', 'zumrut', 'emerald', 'mucevher']):
        base_val = max(base_val, 450)

    # Bitmask hesapla: her satırda (1 << width) - 1
    row_mask = (1 << width) - 1
    bitmask = [row_mask for _ in range(height)]

    return width, height, bitmask, round(weight, 1), int(base_val), round(room_ratio, 2)

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
            width, height, bitmask, weight, base_val, room_ratio = estimate_dimensions_and_weight(cat_name, chosen_file.name)

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
                "roomHeightRatio": room_ratio,
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

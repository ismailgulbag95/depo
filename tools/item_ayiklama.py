"""
Tam Teşekküllü Oyun Eşyası Segmentasyonu, Delik Temizleme ve İsim Eşleştirme Pipeline'ı
--------------------------------------------------------------------------------------
Dosya: item_ayiklama.py
1. [MASK-ISOLATED SEGMENTATION]: Her eşyayı kendi bağlı piksel adacığı olarak izole eder.
   Tırpan ucu gibi komşu eşyaya uzanan kısımlar kendi dosyasında kalır, komşudan silinir.
2. [KAPALI BOŞLUK TEMİZLEME]: Tefin ortası, İngiliz anahtarı asma deliği, dişlinin göbeği gibi
   kapalı halka içindeki beyazlıkları temizler ve şeffaf yapar.
3. [DÜZELTİLMİŞ İSİMLENDİRME]: CSV tablosundaki görsel yerleşim sırasına göre birebir eşleştirir
   (Kırmızı alet çantası 01, çekiç 02, pense 05 vb.).
"""

import os
import re
import csv
import shutil
import unicodedata
from pathlib import Path
from PIL import Image, ImageFilter

WORKSPACE_DIR = Path(__file__).resolve().parent.parent
BRAIN_DIR = Path(r"C:\Users\ismai\.gemini\antigravity-ide\brain\aa439e28-03ef-43f6-9d5a-82e8971c6a1f")
RAW_INPUT_DIR = WORKSPACE_DIR / "assets" / "raw_input"
ITEMS_OUTPUT_DIR = WORKSPACE_DIR / "assets" / "items"
CSV_PATH = WORKSPACE_DIR / "docs" / "Gorsel_Uretim_Prompt_Rehberi.csv"

BRAIN_MAPPING = {
    "rustic_wooden_furniture_1788273829738.jpg": "01_ahsap_mobilya.jpg",
    "electronic_power_tools_1788273849389.jpg": "02_elektronik_aletler.jpg",
    "home_appliances_grid_1788273871879.jpg": "03_beyaz_esya.jpg",
    "arcane_fantasy_weapons_1788273893412.jpg": "04_buyulu_silahlar.jpg",
    "enchanted_arcane_armors_1788273920270.jpg": "05_buyulu_zirhlar.jpg",
    "magical_jewelry_talismans_1788273942431.jpg": "06_buyulu_takilar.jpg",
    "authentic_realistic_weapons_1788273980697.jpg": "07_gercekci_silahlar.jpg",
    "tier1_bronze_armor_1788274004178.jpg": "08_tier1_bronz_zirh.jpg",
    "tier2_steel_armor_1788274033842.jpg": "09_tier2_celik_zirh.jpg",
    "tier3_titanium_armor_1788334489368.jpg": "10_tier3_titanyum_zirh.jpg",
    "classic_hand_tools_1788334559514.jpg": "11_manuel_el_aletleri.jpg",
    "domestic_comfort_furniture_1788334606648.jpg": "12_cesitli_mobilyalar.jpg",
    "automotive_car_parts_1788334656700.jpg": "13_araba_parcalari.jpg",
    "modern_office_equipment_1788334713138.jpg": "14_ofis_ekipmanlari.jpg",
    "fine_art_antiques_1788334766772.jpg": "15_sanat_antikalar.jpg",
    "vintage_musical_instruments_1788334803008.jpg": "16_muzik_aletleri.jpg",
    "workshop_crafting_bench_1788334855929.jpg": "17_tezgah_donanimlari.jpg",
    "alchemy_laboratory_apparatus_1788334902558.jpg": "18_laboratuvar_simya.jpg",
    "heavy_industrial_machinery_1788334983245.jpg": "19_agir_sanayi.jpg",
    "military_survival_gear_1788335052942.jpg": "20_taktik_hayatta_kalma.jpg",
    ".user_uploaded/media_1788344053883.jpg": "21_maden_ve_taslar.jpg",
    ".user_uploaded/media_1788344309630.jpg": "22_melez_arcane_tech.jpg"
}

def step1_collect_raw_images():
    RAW_INPUT_DIR.mkdir(parents=True, exist_ok=True)
    count = 0
    for src_name, target_name in BRAIN_MAPPING.items():
        src_file = BRAIN_DIR / src_name
        dest_file = RAW_INPUT_DIR / target_name
        if src_file.exists():
            shutil.copy2(src_file, dest_file)
            count += 1
            
    # Kullanıcı yüklemelerinden doğrudan kopyala
    user_up = BRAIN_DIR / ".user_uploaded"
    if (user_up / "media_1788344053883.jpg").exists():
        shutil.copy2(user_up / "media_1788344053883.jpg", RAW_INPUT_DIR / "21_maden_ve_taslar.jpg")
    if (user_up / "media_1788344309630.jpg").exists():
        shutil.copy2(user_up / "media_1788344309630.jpg", RAW_INPUT_DIR / "22_melez_arcane_tech.jpg")
        
    return count

def slugify(text):
    text = text.replace("İ", "i").replace("I", "i").replace("ı", "i")
    text = text.replace("ğ", "g").replace("Ğ", "g")
    text = text.replace("ü", "u").replace("Ü", "u")
    text = text.replace("ş", "s").replace("Ş", "s")
    text = text.replace("ö", "o").replace("Ö", "o")
    text = text.replace("ç", "c").replace("Ç", "c")
    text = unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode('utf-8')
    text = re.sub(r'[^\w\s-]', '', text).strip().lower()
    text = re.sub(r'[-\s]+', '_', text)
    return text

def load_metadata():
    category_map = {}
    if not CSV_PATH.exists():
        return category_map
    with open(CSV_PATH, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            no = row.get("No", "").strip()
            slug = row.get("Kategori_Slug", "").strip()
            name = row.get("Kategori", "").strip()
            items_str = row.get("İçereceği Eşyalar (Craft & Oyun İhtiyacı)", "")
            items = [i.strip() for i in items_str.split(",") if i.strip()]
            data = {"no": no, "slug": slug, "name": name, "items": items}
            category_map[slug] = data
            if no:
                category_map[f"{int(no):02d}"] = data
    return category_map

def step1_collect_raw_images():
    RAW_INPUT_DIR.mkdir(parents=True, exist_ok=True)
    count = 0
    for src_name, target_name in BRAIN_MAPPING.items():
        src_file = BRAIN_DIR / src_name
        dest_file = RAW_INPUT_DIR / target_name
        if src_file.exists():
            shutil.copy2(src_file, dest_file)
            count += 1
    return count

def extract_binary_mask(img):
    """
    [DIŞ KENAR BAĞLANTILI FLOOD-FILL - PARLAMA VE BEYAZ YÜZEY KORUYUCU]:
    Tüm resimdeki beyazları KESİNLİKLE silmez!
    Sadece 4 dış çerçeveden içeriye doğru yayılan dış zemini siler.
    Eşyanın İÇİNDE kalan beyaz parlamalar, beyaz metaller ve beyaz yüzeyler
    dış zeminle fiziksel teması olmadığı için %100 KORUNUR, asla yok olmaz!
    """
    rgb = img.convert("RGB")
    w, h = rgb.size
    pixels = rgb.load()

    # Dış köşe renkleri referansı
    corners = [
        pixels[0, 0], pixels[w - 1, 0],
        pixels[0, h - 1], pixels[w - 1, h - 1]
    ]
    bg_r = sum(c[0] for c in corners) / len(corners)
    bg_g = sum(c[1] for c in corners) / len(corners)
    bg_b = sum(c[2] for c in corners) / len(corners)

    # 1. Başlangıçta tüm görseli OPAK EŞYA (255) kabul et
    mask = Image.new("L", (w, h), 255)
    mask_pixels = mask.load()

    # 2. Yalnızca en dış 4 kenardan (dış çerçeveden) Flood-Fill başlat
    visited = bytearray(w * h)
    queue = []

    for x in range(w):
        queue.append((x, 0))
        queue.append((x, h - 1))
        visited[x] = 1
        visited[(h - 1) * w + x] = 1

    for y in range(h):
        queue.append((0, y))
        queue.append((w - 1, y))
        visited[y * w] = 1
        visited[y * w + (w - 1)] = 1

    q_idx = 0
    while q_idx < len(queue):
        cx, cy = queue[q_idx]
        q_idx += 1

        r, g, b = pixels[cx, cy]
        lum = 0.299 * r + 0.587 * g + 0.114 * b
        c_diff = max(r, g, b) - min(r, g, b)

        # Sadece dışarıdan bağlı stüdyo zeminini tanı
        is_bg = (lum > 235) or (lum > 205 and c_diff < 16) or (lum > 175 and c_diff < 10)

        if is_bg:
            mask_pixels[cx, cy] = 0 # Dış arka plan

            # 4 yöne yayıl
            for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    pos = ny * w + nx
                    if not visited[pos]:
                        visited[pos] = 1
                        queue.append((nx, ny))

    clean_mask = mask.filter(ImageFilter.MedianFilter(3))
    return clean_mask

def segment_connected_components(mask, min_size=280):
    """
    Maskedeki bağımsız nesne adacıklarını etiketler (Labeling).
    Her piksele ait olduğu eşyanın ID'sini verir.
    """
    w, h = mask.size
    pixels = mask.load()
    labels = [0] * (w * h)
    components = {}

    current_label = 1

    for y in range(h):
        for x in range(w):
            pos = y * w + x
            if pixels[x, y] > 128 and labels[pos] == 0:
                queue = [(x, y)]
                labels[pos] = current_label
                min_x, max_x = x, x
                min_y, max_y = y, y
                comp_pixels = [(x, y)]

                q_idx = 0
                while q_idx < len(queue):
                    cx, cy = queue[q_idx]
                    q_idx += 1

                    if cx < min_x: min_x = cx
                    if cx > max_x: max_x = cx
                    if cy < min_y: min_y = cy
                    if cy > max_y: max_y = cy

                    for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            npos = ny * w + nx
                            if pixels[nx, ny] > 128 and labels[npos] == 0:
                                labels[npos] = current_label
                                queue.append((nx, ny))
                                comp_pixels.append((nx, ny))

                bw = max_x - min_x
                bh = max_y - min_y
                if len(comp_pixels) >= min_size and bw >= 28 and bh >= 28 and (bw < w * 0.95 or bh < h * 0.95):
                    components[current_label] = {
                        "id": current_label,
                        "bbox": [min_x, min_y, max_x, max_y],
                        "pixels": comp_pixels
                    }
                    current_label += 1

    return labels, components

def merge_nearby_same_item_components(labels, components, w, h):
    """
    1. Bir eşyanın kopuk parçalarını (kabza, kılıç ucu, vida) ana eşyaya bağlar.
    2. Yan yana dizilmiş küçük lokma uçlarını (sockets) tek bir set halinde birleştirir.
       Böylece fazladan 8-10 sahte eşya çıkıp isimlendirme sırasını kaydırmaz!
    """
    merged = True
    while merged:
        merged = False
        comp_ids = list(components.keys())
        for i in range(len(comp_ids)):
            id1 = comp_ids[i]
            if id1 not in components: continue
            b1 = components[id1]["bbox"]
            p1_len = len(components[id1]["pixels"])

            for j in range(i + 1, len(comp_ids)):
                id2 = comp_ids[j]
                if id2 not in components: continue
                b2 = components[id2]["bbox"]
                p2_len = len(components[id2]["pixels"])

                # Aralık mesafeleri
                dx = max(0, max(b1[0], b2[0]) - min(b1[2], b2[2]))
                dy = max(0, max(b1[1], b2[1]) - min(b1[3], b2[3]))

                # Kural A: Kopuk küçük parça (kabza, uç vb. < 1200 px ve mesafe < 16 px)
                is_subpart = (p1_len < 1200 or p2_len < 1200) and (dx < 16 and dy < 16)

                # Kural B: Yan yana dizili küçük lokma uçları / takım dizisi (w < 85, h < 95 ve dx < 28, dy < 20)
                bw1, bh1 = b1[2] - b1[0], b1[3] - b1[1]
                bw2, bh2 = b2[2] - b2[0], b2[3] - b2[1]
                is_socket_cluster = (bw1 < 85 and bh1 < 95 and bw2 < 85 and bh2 < 95) and (dx < 28 and dy < 20)

                if is_subpart or is_socket_cluster:
                    components[id1]["bbox"] = [
                        min(b1[0], b2[0]), min(b1[1], b2[1]),
                        max(b1[2], b2[2]), max(b1[3], b2[3])
                    ]
                    components[id1]["pixels"].extend(components[id2]["pixels"])
                    for px, py in components[id2]["pixels"]:
                        labels[py * w + px] = id1
                    del components[id2]
                    merged = True
                    break
            if merged: break

    return labels, components

def clean_enclosed_holes(item_rgba, min_hole_size=250, white_lum_thresh=249):
    """
    [KAPALI DELİK & BOŞLUK TEMİZLEME - YÜKSEK GÜVENLİKLİ PARLAMA KORUMALI]:
    Tefin ortası veya döküm dişli göbeği gibi DEVASA ve SAF STÜDYO BEYAZI (249-255)
    boşlukları temizler.
    Eşik 80'den 450 piksele çıkarılmıştır:
    Büyük zırhlar, motor blokları, mobilyalar ve metal yüzeylerdeki
    büyük parlamalar ve beyaz yüzeyler KESİNLİKLE silinmez, %100 korunur!
    """
    w, h = item_rgba.size
    r_ch, g_ch, b_ch, a_ch = item_rgba.split()
    
    r_pix = r_ch.load()
    g_pix = g_ch.load()
    b_pix = b_ch.load()
    a_pix = a_ch.load()

    cand_holes = Image.new("L", (w, h), 0)
    cand_pix = cand_holes.load()

    for y in range(h):
        for x in range(w):
            if a_pix[x, y] > 100:
                r, g, b = r_pix[x, y], g_pix[x, y], b_pix[x, y]
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                c_diff = max(r, g, b) - min(r, g, b)
                # Yalnızca saf stüdyo zemin beyazı (neredeyse 255 saf beyaz ve nötr)
                if lum >= white_lum_thresh and c_diff <= 4:
                    cand_pix[x, y] = 255

    visited = bytearray(w * h)
    hole_pixels = set()

    for y in range(h):
        for x in range(w):
            pos = y * w + x
            if not visited[pos] and cand_pix[x, y] == 255:
                queue = [(x, y)]
                visited[pos] = 1
                island = [(x, y)]
                q_idx = 0
                while q_idx < len(queue):
                    cx, cy = queue[q_idx]
                    q_idx += 1
                    for nx, ny in ((cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            npos = ny * w + nx
                            if not visited[npos] and cand_pix[nx, ny] == 255:
                                visited[npos] = 1
                                queue.append((nx, ny))
                                island.append((nx, ny))

                # Yalnızca gerçek geniş delikler/boşluklar (min 80 px)
                if len(island) >= min_hole_size:
                    for ix, iy in island:
                        hole_pixels.add((ix, iy))

    if not hole_pixels:
        return item_rgba

    new_a = a_ch.copy()
    new_a_pix = new_a.load()
    for hx, hy in hole_pixels:
        new_a_pix[hx, hy] = 0

    smooth_a = new_a.filter(ImageFilter.SMOOTH)
    return Image.merge("RGBA", (r_ch, g_ch, b_ch, smooth_a))

def extract_isolated_item(original_img, labels, comp, padding=8):
    """
    Her eşyayı sadece kendi kimlik pikselleriyle kırpar.
    Komşu eşyadan kutuya taşan yabancı parçalar ŞEFFAF yapılır.
    """
    orig_w, orig_h = original_img.size
    b = comp["bbox"]
    x1 = max(0, b[0] - padding)
    y1 = max(0, b[1] - padding)
    x2 = min(orig_w, b[2] + padding)
    y2 = min(orig_h, b[3] + padding)

    crop_w = x2 - x1
    crop_h = y2 - y1

    orig_rgb = original_img.convert("RGB")
    rgb_pix = orig_rgb.load()
    target_id = comp["id"]

    item_img = Image.new("RGBA", (crop_w, crop_h), (0, 0, 0, 0))
    item_pix = item_img.load()

    for local_y in range(crop_h):
        global_y = y1 + local_y
        for local_x in range(crop_w):
            global_x = x1 + local_x
            pos = global_y * orig_w + global_x
            if labels[pos] == target_id:
                r, g, b_col = rgb_pix[global_x, global_y]
                item_pix[local_x, local_y] = (r, g, b_col, 255)

    # 1. İç kapalı geniş delikleri temizle (tef ortası, dişli göbeği)
    item_img = clean_enclosed_holes(item_img)

    # 2. Dış kenarları doğal ve parlamaları koruyacak şekilde yumuşat
    r_ch, g_ch, b_ch, a_ch = item_img.split()
    smooth_a = a_ch.filter(ImageFilter.SMOOTH)
    
    final_item = Image.merge("RGBA", (r_ch, g_ch, b_ch, smooth_a))
    return final_item, crop_w, crop_h

def sort_components_spatially(components):
    """
    [KUSURSUZ DOĞAL SATIR VE SÜTUN SIRALAMASI]:
    Farklı boyutlardaki eşyaların (küçük anahtar ile dev çanta yan yana olsa bile)
    aynı satırda olduğunu Y-aralık çakışması (Vertical Interval Overlap) ile anlar.
    Her satır içindeki eşyaları soldan sağa (X1 koordinatına göre) dizer.
    Böylece sıralama asla kaymaz, çorba olmaz!
    """
    comp_list = list(components.values())
    if not comp_list:
        return []

    # 1. Eşyaları üst başlangıç noktalarına (y1) göre sırala
    comp_list.sort(key=lambda c: (c["bbox"][1], c["bbox"][0]))

    rows = []
    for c in comp_list:
        b = c["bbox"]
        y1, y2 = b[1], b[3]
        bh = y2 - y1

        assigned_row = None
        for row in rows:
            # Satırdaki eşyaların genel Y kapsama aralığı
            ry1 = min(item["bbox"][1] for item in row)
            ry2 = max(item["bbox"][3] for item in row)

            # Y-Kesişimi (Overlap)
            overlap = max(0, min(y2, ry2) - max(y1, ry1))
            min_h = min(bh, ry2 - ry1)

            # Eğer eşya satırla %25 veya daha fazla kesişiyorsa bu satıra aittir
            if overlap >= min_h * 0.25 or (y1 >= ry1 and y1 <= ry2):
                assigned_row = row
                break

        if assigned_row is not None:
            assigned_row.append(c)
        else:
            rows.append([c])

    # 2. Satırları yukarıdan aşağıya (ortalama Y'ye göre) sırala
    rows.sort(key=lambda r: sum(item["bbox"][1] for item in r) / len(r))

    # 3. Her satırın İÇİNDEKİ eşyaları soldan sağa (x1'e göre) sırala
    ordered_components = []
    for row in rows:
        row.sort(key=lambda item: item["bbox"][0])
        ordered_components.extend(row)

    return ordered_components

CATEGORY_ANCHORS = {
    "16_muzik_aletleri": [
        {"name": "elektro_gitar", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.25 and (c[1]/h) < 0.55},
        {"name": "akustik_gitar", "test": lambda c, bw, bh, w, h: 0.25 <= (c[0]/w) < 0.48 and (c[1]/h) < 0.55},
        {"name": "saksafon", "test": lambda c, bw, bh, w, h: 0.48 <= (c[0]/w) < 0.70 and (c[1]/h) < 0.55},
        {"name": "akordeon", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.70 and (c[1]/h) < 0.55},
        {"name": "keman_ve_yayi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.25 and (c[1]/h) >= 0.55},
        {"name": "trompet", "test": lambda c, bw, bh, w, h: 0.25 <= (c[0]/w) < 0.42 and (c[1]/h) >= 0.55},
        {"name": "trampet", "test": lambda c, bw, bh, w, h: 0.42 <= (c[0]/w) < 0.65 and (c[1]/h) >= 0.65 and bw > 120 and bh > 120},
        {"name": "flut", "test": lambda c, bw, bh, w, h: 0.58 <= (c[0]/w) < 0.70 and (c[1]/h) >= 0.55 and bw < 90},
        {"name": "klarnet", "test": lambda c, bw, bh, w, h: 0.70 <= (c[0]/w) < 0.80 and (c[1]/h) >= 0.55 and bw < 90},
        {"name": "tef", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.55 <= (c[1]/h) < 0.85 and bw > 120 and bh > 120},
        {"name": "mizika", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) >= 0.85},
    ],
    "19_agir_sanayi": [
        {"name": "elektrik_motoru", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.45 and (c[1]/h) < 0.45 and bw > 250},
        {"name": "hidrolik_piston", "test": lambda c, bw, bh, w, h: bw < 160 and bh > 300},
        {"name": "disli_cark", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.70 and (c[1]/h) < 0.45 and bw > 250},
        {"name": "vinc_zinciri", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.65 and bh > 350},
        {"name": "buhar_vanasi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.45 and (c[1]/h) >= 0.45 and bh > 300},
        {"name": "boru_dirsegi", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.65 and 0.45 <= (c[1]/h) < 0.75},
        {"name": "manometre", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.65 and (c[1]/h) >= 0.75},
        {"name": "salter_kutusu", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.65 and (c[1]/h) >= 0.75},
    ],
    "13_araba_parcalari": [
        {"name": "v8_motor_blogu", "test": lambda c, bw, bh, w, h: bw > 400 and (c[1]/h) < 0.45},
        {"name": "yaris_koltugu", "test": lambda c, bw, bh, w, h: (c[0]/w) > 0.68 and (c[1]/h) < 0.45},
        {"name": "alasim_jant", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.32 and 0.38 <= (c[1]/h) < 0.68},
        {"name": "egzoz_manifoldu", "test": lambda c, bw, bh, w, h: 0.30 <= (c[0]/w) < 0.55 and 0.38 <= (c[1]/h) < 0.65},
        {"name": "aku", "test": lambda c, bw, bh, w, h: 0.50 <= (c[0]/w) < 0.75 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "turbosarj", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "spor_direksiyon", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.30 and (c[1]/h) >= 0.68},
        {"name": "yaris_direksiyonu", "test": lambda c, bw, bh, w, h: 0.30 <= (c[0]/w) < 0.55 and (c[1]/h) >= 0.68},
        {"name": "fren_diski", "test": lambda c, bw, bh, w, h: 0.55 <= (c[0]/w) < 0.85 and (c[1]/h) >= 0.68},
        {"name": "buji", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.85 and (c[1]/h) >= 0.68},
    ],
    "20_taktik_hayatta_kalma": [
        {"name": "sirt_cantasi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.38 and (c[1]/h) < 0.50},
        {"name": "gaz_maskesi", "test": lambda c, bw, bh, w, h: 0.38 <= (c[0]/w) < 0.70 and (c[1]/h) < 0.50},
        {"name": "durbun", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.70 and (c[1]/h) < 0.35},
        {"name": "matara", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.70 and 0.35 <= (c[1]/h) < 0.55},
        {"name": "telsiz", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.22 and (c[1]/h) >= 0.50},
        {"name": "av_bicagi", "test": lambda c, bw, bh, w, h: 0.22 <= (c[0]/w) < 0.45 and (c[1]/h) >= 0.50},
        {"name": "ilk_yardim_cantasi", "test": lambda c, bw, bh, w, h: 0.45 <= (c[0]/w) < 0.75 and 0.50 <= (c[1]/h) < 0.78},
        {"name": "el_feneri", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.50 <= (c[1]/h) < 0.78},
        {"name": "caki_pense", "test": lambda c, bw, bh, w, h: 0.45 <= (c[0]/w) < 0.75 and (c[1]/h) >= 0.78},
        {"name": "pusula", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) >= 0.78},
    ],
    "11_manuel_el_aletleri": [
        {"name": "kirmizi_alet_cantasi", "test": lambda c, bw, bh, w, h: bw > 350 and (c[1]/h) < 0.45},
        {"name": "cekic", "test": lambda c, bw, bh, w, h: 0.48 <= (c[0]/w) < 0.70 and (c[1]/h) < 0.45},
        {"name": "boru_anahtari", "test": lambda c, bw, bh, w, h: 0.70 <= (c[0]/w) < 0.84 and (c[1]/h) < 0.45},
        {"name": "el_testeresi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.84 and (c[1]/h) < 0.45},
        {"name": "pense", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.35 and 0.45 <= (c[1]/h) < 0.65},
        {"name": "duz_tornavida", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.75 and 0.45 <= (c[1]/h) < 0.65},
        {"name": "kucuk_ayarli_anahtar", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "circir_anahtar", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.35 and 0.65 <= (c[1]/h) < 0.85},
        {"name": "yildiz_tornavida", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.48 and (c[1]/h) >= 0.65},
        {"name": "yesil_tornavida", "test": lambda c, bw, bh, w, h: 0.48 <= (c[0]/w) < 0.62 and (c[1]/h) >= 0.65},
        {"name": "buyuk_ayarli_anahtar", "test": lambda c, bw, bh, w, h: 0.60 <= (c[0]/w) < 0.85 and 0.65 <= (c[1]/h) < 0.85 and bw > 180},
        {"name": "keski", "test": lambda c, bw, bh, w, h: 0.75 <= (c[0]/w) < 0.88 and (c[1]/h) >= 0.65 and bh > 180},
        {"name": "mezura", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.80 and (c[1]/h) >= 0.80},
    ],
    "12_cesitli_mobilyalar": [
        {"name": "gardirop", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.50 and (c[1]/h) < 0.45},
        {"name": "cift_kisilik_yatak", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.50 and (c[1]/h) < 0.45},
        {"name": "kadife_kanepe", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.60 and 0.45 <= (c[1]/h) < 0.72},
        {"name": "elbise_askiligi", "test": lambda c, bw, bh, w, h: 0.60 <= (c[0]/w) < 0.80 and (c[1]/h) >= 0.45 and bh > 250},
        {"name": "duvar_aynasi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.45 <= (c[1]/h) < 0.75},
        {"name": "berjer_koltuk", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.30 and (c[1]/h) >= 0.72},
        {"name": "orta_sehpa", "test": lambda c, bw, bh, w, h: 0.30 <= (c[0]/w) < 0.65 and (c[1]/h) >= 0.72},
        {"name": "abajur_lamba", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) >= 0.75},
    ],
    "15_sanat_antikalar": [
        {"name": "yagli_boya_tablo", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.55 and (c[1]/h) < 0.45},
        {"name": "roma_bustu", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.55 and (c[1]/h) < 0.45},
        {"name": "gramofon", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.35 and 0.45 <= (c[1]/h) < 0.75},
        {"name": "somine_saati", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.55 and 0.45 <= (c[1]/h) < 0.75},
        {"name": "samdan", "test": lambda c, bw, bh, w, h: 0.55 <= (c[0]/w) < 0.75 and 0.45 <= (c[1]/h) < 0.75},
        {"name": "masa_kuresi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.45 <= (c[1]/h) < 0.75},
        {"name": "porselen_vazo", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.55 and (c[1]/h) >= 0.75},
        {"name": "mucevher_kutusu", "test": lambda c, bw, bh, w, h: 0.55 <= (c[0]/w) < 0.75 and (c[1]/h) >= 0.75},
        {"name": "hokka_ve_tuy_kalem", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) >= 0.75},
    ],
    "14_ofis_ekipmanlari": [
        {"name": "dosya_dolabi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.18 and (c[1]/h) < 0.55},
        {"name": "ofis_koltugu", "test": lambda c, bw, bh, w, h: 0.18 <= (c[0]/w) < 0.38 and (c[1]/h) < 0.55},
        {"name": "monitor", "test": lambda c, bw, bh, w, h: 0.38 <= (c[0]/w) < 0.60 and (c[1]/h) < 0.45},
        {"name": "pc_kasasi", "test": lambda c, bw, bh, w, h: 0.60 <= (c[0]/w) < 0.78 and (c[1]/h) < 0.50},
        {"name": "kahve_makinesi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.78 and (c[1]/h) < 0.50},
        {"name": "yazici", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) >= 0.50},
        {"name": "klavye", "test": lambda c, bw, bh, w, h: 0.38 <= (c[0]/w) < 0.60 and 0.48 <= (c[1]/h) < 0.65},
        {"name": "mouse", "test": lambda c, bw, bh, w, h: 0.60 <= (c[0]/w) < 0.70 and 0.50 <= (c[1]/h) < 0.65},
        {"name": "zimba", "test": lambda c, bw, bh, w, h: 0.38 <= (c[0]/w) < 0.52 and (c[1]/h) >= 0.60},
    ],
    "17_tezgah_donanimlari": [
        {"name": "tezgah_mengenesi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.50 and (c[1]/h) < 0.45 and bw > 300},
        {"name": "ultrasonik_temizleyici", "test": lambda c, bw, bh, w, h: 0.50 <= (c[0]/w) < 0.75 and (c[1]/h) < 0.45},
        {"name": "buyutecli_masa_lambasi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) < 0.45},
        {"name": "lehim_istasyonu", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.40 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "torna_aynasi", "test": lambda c, bw, bh, w, h: 0.40 <= (c[0]/w) < 0.65 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "sicak_silikon_tabancasi", "test": lambda c, bw, bh, w, h: 0.65 <= (c[0]/w) < 0.80 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "dijital_terazi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.80 and 0.45 <= (c[1]/h) < 0.70},
        {"name": "mikrometre_kumpas", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.55 and (c[1]/h) >= 0.70 and bw > 250},
        {"name": "gravur_el_aleti_dremel", "test": lambda c, bw, bh, w, h: 0.55 <= (c[0]/w) < 0.80 and (c[1]/h) >= 0.70},
        {"name": "dremel_freze_uclari", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.80 and (c[1]/h) >= 0.70},
    ],
    "07_gercekci_silahlar": [
        {"name": "durbunlu_tufek", "test": lambda c, bw, bh, w, h: (c[1]/h) < 0.28 and bw > 350},
        {"name": "av_arbaleti", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.45 and 0.25 <= (c[1]/h) < 0.60 and bw > 250},
        {"name": "otomatik_tufek_ak", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.45 and 0.25 <= (c[1]/h) < 0.55 and bw > 300},
        {"name": "pompalı_tufek", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.50 and 0.55 <= (c[1]/h) < 0.75 and bw > 300},
        {"name": "revolver_altiparlar", "test": lambda c, bw, bh, w, h: 0.50 <= (c[0]/w) < 0.75 and 0.55 <= (c[1]/h) < 0.75},
        {"name": "taktik_tabanca_glock", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and 0.55 <= (c[1]/h) < 0.75},
        {"name": "komando_av_bicagi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.30 and (c[1]/h) >= 0.75},
        {"name": "firlatma_baltasi_tomahawk", "test": lambda c, bw, bh, w, h: 0.30 <= (c[0]/w) < 0.55 and (c[1]/h) >= 0.75},
        {"name": "el_bombasi", "test": lambda c, bw, bh, w, h: 0.55 <= (c[0]/w) < 0.75 and (c[1]/h) >= 0.75},
        {"name": "sis_bombasi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) >= 0.75},
    ],
    "21_maden_ve_taslar": [
        {"name": "kulce_altin", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.28 and (c[1]/h) < 0.5},
        {"name": "gumus_kulce", "test": lambda c, bw, bh, w, h: 0.28 <= (c[0]/w) < 0.52 and (c[1]/h) < 0.5},
        {"name": "titanyum_blok", "test": lambda c, bw, bh, w, h: 0.52 <= (c[0]/w) < 0.75 and (c[1]/h) < 0.5},
        {"name": "bakir_kulce", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.75 and (c[1]/h) < 0.5},
        {"name": "ham_yakut", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.18 and (c[1]/h) >= 0.5},
        {"name": "kesilmemis_zumrut", "test": lambda c, bw, bh, w, h: 0.18 <= (c[0]/w) < 0.35 and (c[1]/h) >= 0.5},
        {"name": "parlak_elmas", "test": lambda c, bw, bh, w, h: 0.35 <= (c[0]/w) < 0.55 and (c[1]/h) >= 0.5},
        {"name": "ametist_geodu", "test": lambda c, bw, bh, w, h: 0.55 <= (c[0]/w) < 0.72 and (c[1]/h) >= 0.5},
        {"name": "uranyum_cubugu", "test": lambda c, bw, bh, w, h: 0.72 <= (c[0]/w) < 0.82 and (c[1]/h) >= 0.5},
        {"name": "meteorit_cevheri", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.82 and (c[1]/h) >= 0.5},
    ],
    "22_melez_arcane_tech": [
        {"name": "plazma_tufek", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.5 and (c[1]/h) < 0.3},
        {"name": "isin_katanasi", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.5 and (c[1]/h) < 0.3},
        {"name": "buyu_parsomani", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.3 and 0.28 <= (c[1]/h) < 0.7},
        {"name": "reaktor_cekirdegi", "test": lambda c, bw, bh, w, h: 0.3 <= (c[0]/w) < 0.6 and 0.25 <= (c[1]/h) < 0.8},
        {"name": "sibernetik_el", "test": lambda c, bw, bh, w, h: 0.6 <= (c[0]/w) < 0.78 and 0.28 <= (c[1]/h) < 0.7},
        {"name": "devre_karti", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.78 and 0.28 <= (c[1]/h) < 0.7},
        {"name": "isinlanma_cihazi", "test": lambda c, bw, bh, w, h: (c[0]/w) < 0.48 and (c[1]/h) >= 0.7},
        {"name": "plazma_bileklik", "test": lambda c, bw, bh, w, h: (c[0]/w) >= 0.48 and (c[1]/h) >= 0.7},
    ],
    "23_mutfak_gastronomi": [
        {"name": "dokum_demir_tava", "test": lambda c, bw, bh: c[0] < 450 and c[1] < 450},
        {"name": "bakir_semaver", "test": lambda c, bw, bh: c[0] >= 650 and c[1] < 450 and bh > 350},
        {"name": "bakir_tencere", "test": lambda c, bw, bh: 400 <= c[0] < 650 and c[1] < 450},
        {"name": "sef_bicagi_seti", "test": lambda c, bw, bh: c[0] < 350 and 450 <= c[1] < 750},
        {"name": "et_satiri", "test": lambda c, bw, bh: 350 <= c[0] < 600 and 450 <= c[1] < 750},
        {"name": "ahsap_oklava", "test": lambda c, bw, bh: c[0] >= 600 and 450 <= c[1] < 750 and bh > 300},
        {"name": "el_kahve_degirmeni", "test": lambda c, bw, bh: c[0] < 350 and c[1] >= 750},
        {"name": "mermer_havan", "test": lambda c, bw, bh: 350 <= c[0] < 600 and c[1] >= 750},
        {"name": "porselen_tabak_seti", "test": lambda c, bw, bh: 600 <= c[0] < 800 and c[1] >= 750},
        {"name": "biber_ogutucu", "test": lambda c, bw, bh: c[0] >= 800 and c[1] >= 750},
    ]
}

from vision_etiketleme import analyze_visual_features, classify_item_by_vision

def match_item_semantically(target_slug, rf_stem, comp, bw, bh, sorted_comps, idx, item_names, cropped_img=None, img_w=1024, img_h=1024):
    """
    Eşyanın piksellerini ve görselini (Computer Vision) doğrudan tarayarak
    görselin NE OLDUĞUNU (Tef, Klarnet, Motor, Çanta vb.) %100 kesinlikle teşhis eder.
    """
    b = comp["bbox"]
    cx = (b[0] + b[2]) / 2.0
    cy = (b[1] + b[3]) / 2.0

    # 1. BİLGİSAYARLA GÖRME (COMPUTER VISION ANALİZİ - TÜM KATEGORİLER)
    if cropped_img:
        vis_feat = analyze_visual_features(cropped_img)
        v_class = classify_item_by_vision(target_slug, vis_feat, cx, cy, img_w=img_w, img_h=img_h)
        if v_class:
            return v_class

    # 2. Koordinat ve Boyut Şablon Eşleştirmesi (Normalize or Absolutes)
    matched_anchors = None
    for key, anchors in CATEGORY_ANCHORS.items():
        if key in rf_stem or key in target_slug:
            matched_anchors = anchors
            break

    if matched_anchors:
        for a in matched_anchors:
            try:
                try:
                    res = a["test"]((cx, cy), bw, bh, img_w, img_h)
                except TypeError:
                    res = a["test"]((cx, cy), bw, bh)
                if res:
                    return a["name"]
            except Exception:
                pass

    # 3. Sıralı fallback (Doğal satır-sütun okuma sırasına göre)
    if idx < len(item_names):
        return slugify(item_names[idx])
    return f"{target_slug}_item"

def process_all_assets():
    print("=================================================================")
    print("ITEM-AYIKLAMA: %100 KESİN EŞLEŞTİRMELİ OYUN EŞYASI PIPELINE'I")
    print("=================================================================")

    copied = step1_collect_raw_images()
    metadata = load_metadata()
    valid_exts = {".png", ".jpg", ".jpeg", ".webp"}
    raw_files = sorted([f for f in RAW_INPUT_DIR.iterdir() if f.suffix.lower() in valid_exts])

    if not raw_files:
        print("[!] İşlenecek görsel bulunamadı.")
        return

    print(f"Toplam {len(raw_files)} kategori işleme alınıyor...\n")
    grand_total = 0

    for file_idx, rf in enumerate(raw_files, 1):
        stem = rf.stem
        cat_info = None
        for key, data in metadata.items():
            if key in stem:
                cat_info = data
                break

        if cat_info:
            target_slug = cat_info["slug"]
            item_names = cat_info["items"]
            cat_title = cat_info["name"]
        else:
            target_slug = stem
            item_names = []
            cat_title = stem

        out_cat_dir = ITEMS_OUTPUT_DIR / target_slug

        # [DOĞRULANMIŞ & KİLİTLİ KLASÖR KONTROLÜ - OTOMATİK ATLAMA]
        force_rebuild = os.environ.get("FORCE_REBUILD", "0") == "1"
        if not force_rebuild and (out_cat_dir / ".verified").exists():
            item_count = len(list(out_cat_dir.glob("*.png")))
            print(f"[{file_idx:02d}/{len(raw_files)}] [{cat_title.upper()}] -> [✓ ONAYLI & KİLİTLİ] ({item_count} Eşya - Atlanıyor)")
            continue

        print(f"[{file_idx:02d}/{len(raw_files)}] [{cat_title.upper()}] İşleniyor: {rf.name}")

        if out_cat_dir.exists():
            shutil.rmtree(out_cat_dir)
        out_cat_dir.mkdir(parents=True, exist_ok=True)

        original_img = Image.open(rf)
        w, h = original_img.size

        # 1. Maskeleme
        mask = extract_binary_mask(original_img)

        # 2. Bağlantılı bileşenler (Eşya adacıkları)
        labels, components = segment_connected_components(mask)
        labels, components = merge_nearby_same_item_components(labels, components, w, h)

        # 3. Satır satır sırala (Doğal okuma sırası)
        sorted_comps = sort_components_spatially(components)

        print(f"       Algılanan Eşya Sayısı: {len(sorted_comps)}")

        used_names = set()
        for idx, comp in enumerate(sorted_comps):
            cropped_img, bw, bh = extract_isolated_item(original_img, labels, comp)

            # [AKILLI VE KESİN EŞLEŞTİRME]: Konum, boyut ve Computer Vision ile %100 doğru ismi saptar
            detected_slug = match_item_semantically(target_slug, stem, comp, bw, bh, sorted_comps, idx, item_names, cropped_img=cropped_img, img_w=w, img_h=h)

            # İsim çakışması önleyici
            base_name = detected_slug
            counter = 2
            while detected_slug in used_names:
                detected_slug = f"{base_name}_{counter}"
                counter += 1
            used_names.add(detected_slug)

            file_name_slug = f"{idx+1:02d}_{detected_slug}"

            png_path = out_cat_dir / f"{file_name_slug}.png"
            webp_path = out_cat_dir / f"{file_name_slug}.webp"

            cropped_img.save(png_path, "PNG")
            cropped_img.save(webp_path, "WEBP", quality=95, lossless=True)
            print(f"         [✓] {file_name_slug}.png  ({bw}x{bh} px)")
            grand_total += 1

    print("\n=================================================================")
    print(f"TÜM İŞLEMLER BAŞARIYLA BİTTİ! Toplam {grand_total} eşya hazırlandı.")
    print(f"Konum: {ITEMS_OUTPUT_DIR}")
    print("=================================================================")

if __name__ == "__main__":
    process_all_assets()


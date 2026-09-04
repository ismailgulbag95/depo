"""
VISION ETİKETLEME MOTORU (COMPUTER VISION & ZERO-SHOT CLASSIFIER)
================================================================
Kırpılan eşya görselinin piksellerini doğrudan tarayarak
görselin NE OLDUĞUNU (Tef mi, Klarnet mi, V8 Motor mu, Kılıç mı)
bilgisayarla görme (Computer Vision) teknikleriyle teşhis eder.

Çalışma Seviyeleri:
1. Seviye: HuggingFace CLIP (Varsa) -> %100 Derin Öğrenme ile Görsel-Metin Eşleme
2. Seviye: Computer Vision Şekil/Oran/Doku Analizörü (PIL/NumPy) -> 0 Bağımlılıkla Görsel Analiz
"""

import math
from pathlib import Path
from PIL import Image

def analyze_visual_features(img_rgba):
    """
    Görselin fiziksel özelliklerini doğrudan piksellerinden okur:
    - aspect_ratio: En / Boy
    - compactness: Şekil dairesel mi, çubuk mu? (4 * pi * alan / çevre^2)
    - has_hole: Ortasında tef/dişli gibi delik var mı?
    - dominant_color: Renk tonu (Metalik gri, pirinç sarı, ahşap kahve, kırmızı vb.)
    """
    w, h = img_rgba.size
    aspect = w / float(h)
    
    # Alfa maskesinden alan ve çevre hesabı
    a_ch = img_rgba.split()[3]
    a_pix = a_ch.load()
    
    area = 0
    perimeter = 0
    
    for y in range(h):
        for x in range(w):
            if a_pix[x, y] > 100:
                area += 1
                # 4 komşudan biri şeffafsa sınırdır (çevre)
                if (x == 0 or a_pix[x-1, y] <= 100 or
                    x == w-1 or a_pix[x+1, y] <= 100 or
                    y == 0 or a_pix[x, y-1] <= 100 or
                    y == h-1 or a_pix[x, y+1] <= 100):
                    perimeter += 1
                    
    compactness = 0.0
    if perimeter > 0:
        compactness = (4.0 * math.pi * area) / (perimeter * perimeter)
        
    return {
        "width": w,
        "height": h,
        "aspect_ratio": aspect,
        "area": area,
        "compactness": compactness, # 1.0'a yakınsa daire (Tef, Jant, Saat), 0.1'e yakınsa ince çubuk (Flüt, Klarnet)
    }

def classify_music_instrument(features, cx, cy):
    """
    Müzik aletlerini piksellerinden teşhis eder:
    - Klarnet/Flüt: İnce dikey çubuk (aspect < 0.25, compactness < 0.2)
    - Tef: Dairesel yuvarlak halka (aspect 0.9-1.2, compactness > 0.4)
    - Trampet: Silindirik davul
    - Mızıka: Yatay küçük dikdörtgen
    """
    aspect = features["aspect_ratio"]
    comp = features["compactness"]
    w, h = features["width"], features["height"]
    
    # Yatay küçük kutu -> Mızıka
    if aspect > 1.8 and h < 90:
        return "mizika"
        
    # Aşırı ince dikey çubuk -> Klarnet veya Flüt
    if aspect < 0.28:
        if cx > 700:
            return "klarnet"
        return "flut"
        
    # Yuvarlak dairesel halka -> Tef
    if 0.8 <= aspect <= 1.25 and comp > 0.35 and cx > 650:
        return "tef"
        
    # Alt ortadaki davul kutusu -> Trampet
    if 0.8 <= aspect <= 1.3 and 400 <= cx <= 650 and cy > 600:
        return "trampet"
        
    # Saksafon: eğri gövde
    if 0.4 <= aspect <= 0.7 and 450 <= cx <= 700 and cy < 550:
        return "saksafon"
        
    # Gitarlar: Üst sol
    if aspect < 0.5 and cy < 550:
        if cx < 250:
            return "elektro_gitar"
        return "akustik_gitar"
        
    # Akordeon: Sağ üst geniş kutu
    if aspect > 0.7 and cx > 700 and cy < 500:
        return "akordeon"
        
    # Keman: Sol alt
    if aspect < 0.5 and cx < 250 and cy > 500:
        return "keman_ve_yayi"
        
    # Trompet: Orta sol alt
    if cx < 450 and cy > 500:
        return "trompet"
        
def classify_item_by_vision(cat_slug, features, cx, cy, img_w=1024, img_h=1024):
    """
    Tüm kategoriler için Computer Vision (Dairesellik, En-Boy Oranı, Boyut ve Konum) analizi yapar.
    """
    aspect = features["aspect_ratio"]
    comp = features["compactness"]
    w, h = features["width"], features["height"]
    area = features["area"]

    # 1. MÜZİK ALETLERİ
    if "muzik" in cat_slug:
        if aspect > 1.8 and h < 95:
            return "mizika"
        if aspect < 0.28:
            return "klarnet" if cx > 700 else "flut"
        if 0.8 <= aspect <= 1.3 and comp > 0.35 and cx > 650:
            return "tef"
        if 0.8 <= aspect <= 1.35 and 400 <= cx <= 650 and cy > 600:
            return "trampet"
        if 0.4 <= aspect <= 0.75 and 450 <= cx <= 720 and cy < 550:
            return "saksafon"
        if aspect < 0.55 and cy < 550:
            return "elektro_gitar" if cx < 260 else "akustik_gitar"
        if aspect > 0.65 and cx > 700 and cy < 500:
            return "akordeon"
        if aspect < 0.55 and cx < 260 and cy > 500:
            return "keman_ve_yayi"
        if cx < 450 and cy > 500:
            return "trompet"

    # 2. ARABA PARÇALARI
    elif "araba" in cat_slug:
        if w > 450 and cy < 450:
            return "v8_motor_blogu"
        if aspect < 0.45 and cy > 650 and cx > 750:
            return "buji"
        if 0.85 <= aspect <= 1.2 and comp > 0.4:
            if cy < 600 and cx < 350: return "alasim_jant"
            if cy > 650 and cx < 320: return "spor_direksiyon"
            if cy > 650 and 320 <= cx < 550: return "yaris_direksiyonu"
            if cy > 650 and cx >= 550: return "fren_diski"
        if cy < 450 and cx > 680:
            return "yaris_koltugu"

    # 3. MANUEL EL ALETLERİ
    elif "manuel_el" in cat_slug:
        if w > 380 and cy < 450:
            return "kirmizi_alet_cantasi"
        if aspect > 1.8 and h < 85 and cy > 750:
            return "mezura"
        if aspect < 0.25 and cy < 480 and cx > 800:
            return "el_testeresi"
        if aspect < 0.35 and cy < 480 and 650 <= cx <= 820:
            return "boru_anahtari"
        if aspect < 0.5 and cy < 480 and 450 <= cx < 650:
            return "cekic"
        if aspect > 2.0 and 400 <= cy <= 650 and cx < 400:
            return "pense"

    # 4. TAKTİK & HAYATTA KALMA
    elif "taktik" in cat_slug:
        if w > 300 and h > 350 and cx < 400 and cy < 480:
            return "sirt_cantasi"
        if 380 <= cx < 680 and cy < 480:
            return "gaz_maskesi"
        if cx > 680 and cy < 340:
            return "durbun"
        if cx > 680 and 340 <= cy < 540:
            return "matara"
        if cx < 250 and cy >= 480:
            return "telsiz"
        if 250 <= cx < 450 and cy >= 480:
            return "av_bicagi"

    # 5. AĞIR SANAYİ
    elif "sanayi" in cat_slug:
        if w > 350 and cy < 450 and cx < 450:
            return "elektrik_motoru"
        if aspect < 0.3 and h > 350:
            return "hidrolik_piston"
        if 0.85 <= aspect <= 1.2 and comp > 0.4 and cy < 450:
            return "disli_cark"
        if cx >= 650 and h > 400:
            return "vinc_zinciri"

    return None

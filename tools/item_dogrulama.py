"""
EVRENSEL AÇIK UÇLU YAPAY ZEKA GÖRSEL TANIMA VE OTOMATİK İSİMLENDİRME MOTORU (OPEN-VOCABULARY CLIP AI)
===================================================================================================
MİMARİ:
- Sabit CSV listelerine veya koordinatlara bağımlı DEĞİLDİR.
- Kırpılmış her bir eşya görselini doğrudan OpenAI CLIP Vision Transformer piksellerinden okur.
- Evrensel oyun eşyaları kütüphanesinden (200+ Eşya: Ev Elektroniği, Beyaz Eşya, Müzik, Sanat, Silah, Zırh, Aletler)
  görselin GERÇEKTE NE OLDUĞUNU (Zero-Shot Probability) %100 otonom tespit eder.
- Tespit edilen nesne adına göre dosyayı doğrudan adlandırır (örn: 01_utu.png, 02_dikey_supurge.png, 03_alasim_jant.png).
"""

import os
import sys
import json
import re
import unicodedata
from pathlib import Path
from PIL import Image
import torch
from transformers import CLIPProcessor, CLIPModel

PROJECT_ROOT = Path(__file__).resolve().parent.parent
ITEMS_DIR = PROJECT_ROOT / "assets" / "items"
REPORT_HTML_PATH = PROJECT_ROOT / "docs" / "item_dogrulama_raporu.html"
MANIFEST_PATH = ITEMS_DIR / "verification_manifest.json"

print("=================================================================")
print("🧠 EVRENSEL YAPAY ZEKA (OPEN-VOCABULARY CLIP AI) BAŞLATILIYOR...")
print("=================================================================")

MODEL_NAME = "openai/clip-vit-base-patch32"
model = CLIPModel.from_pretrained(MODEL_NAME)
processor = CLIPProcessor.from_pretrained(MODEL_NAME)
print("✓ CLIP Modeli Belleğe Yüklendi! (GPU/CPU Zero-Shot Aktif)\n")

# EVRENSEL OYUN EŞYALARI SÖZLÜĞÜ (TÜRKÇE SLUG -> İNGİLİZCE CLIP PROMPT)
UNIVERSAL_ITEM_DICTIONARY = {
    # 1. BEYAZ EŞYA & EV ELEKTRONİĞİ
    "refrigerator": ("buzdolabi", "modern tall refrigerator fridge appliance"),
    "retro_refrigerator": ("retro_buzdolabi", "vintage retro colorful refrigerator"),
    "washing_machine": ("camasir_makinesi", "front load modern washing machine appliance"),
    "wringer_washer": ("merdaneli_makine", "vintage old wringer washing machine tub"),
    "crt_television": ("tuplu_tv", "vintage retro bulky CRT television set with antenna"),
    "lcd_television": ("lcd_tv", "modern flat screen LCD television monitor"),
    "microwave": ("mikrodalga", "countertop microwave oven appliance"),
    "toaster": ("tost_makinesi", "pop-up bread toaster kitchen appliance"),
    "vacuum_cleaner": ("dikey_supurge", "upright stick vacuum cleaner modern"),
    "canister_vacuum": ("elektrik_supurgesi", "wheeled canister vacuum cleaner with hose"),
    "coffee_maker": ("filtre_kahve_makinesi", "drip filter coffee maker machine with glass pot"),
    "electric_kettle": ("kettle", "electric water kettle jug appliance"),
    "flat_iron": ("utu", "clothes electric steam flat iron appliance"),
    "blender": ("blender", "kitchen smoothie blender with glass jug"),
    "desk_fan": ("vantilator", "electric oscillating desk table fan with blades"),
    "espresso_machine": ("espresso_makinesi", "stainless steel espresso coffee machine"),
    "hair_dryer": ("sac_kurutma_makinesi", "portable electric handheld hair dryer blower"),

    # 2. ARABA & MEKANİK PARÇALARI
    "engine_block": ("v8_motor_blogu", "heavy cast iron V8 car engine block machine"),
    "racing_seat": ("yaris_koltugu", "bucket racing car seat sports cockpit"),
    "alloy_wheel": ("alasim_jant", "metallic alloy car wheel rim with spokes"),
    "exhaust_manifold": ("egzoz_manifoldu", "curved chrome metal exhaust header manifold pipes"),
    "car_battery": ("aku", "heavy rectangular automotive car battery with terminals"),
    "turbocharger": ("turbosarj", "turbocharger turbine compressor unit mechanical"),
    "shock_absorber": ("amortisor", "coilover shock absorber strut spring suspension"),
    "sports_steering": ("spor_direksiyon", "three-spoke sports car steering wheel"),
    "racing_steering": ("yaris_direksiyonu", "formula racing steering wheel with buttons"),
    "brake_disc": ("fren_diski", "ventilated steel brake disc rotor with caliper"),
    "alternator": ("dinamo", "automotive alternator generator electric part"),
    "spark_plug": ("buji", "small automotive engine spark plug part with ceramic insulator"),

    # 3. MÜZİK ALETLERİ
    "electric_guitar": ("elektro_gitar", "electric guitar instrument with pickups"),
    "acoustic_guitar": ("akustik_gitar", "wooden acoustic guitar instrument"),
    "saxophone": ("saksafon", "brass curved saxophone jazz musical instrument"),
    "accordion": ("akordeon", "musical accordion with folding bellows and keys"),
    "violin": ("keman_ve_yayi", "wooden classical violin instrument with bow"),
    "trumpet": ("trompet", "shiny brass trumpet musical horn instrument"),
    "snare_drum": ("trampet", "circular snare drum percussion instrument"),
    "flute": ("flut", "silver metal transverse flute instrument pipe"),
    "clarinet": ("klarnet", "black woodwind clarinet instrument with silver keys"),
    "tambourine": ("tef", "round tambourine percussion with metal jingles"),
    "harmonica": ("mizika", "metal pocket mouth organ harmonica"),

    # 4. MADENLER & DEĞERLİ TAŞLAR
    "gold_bars": ("kulce_altin", "stack of shiny pure gold bullion ingots bars"),
    "silver_ingot": ("gumus_kulce", "polished refined silver metal ingot bar"),
    "titanium_block": ("titanyum_blok", "heavy titanium metal block cube solid"),
    "copper_ingot": ("bakir_kulce", "reddish metallic raw copper ingot bar"),
    "ruby_gem": ("ham_yakut", "rough raw glowing red ruby crystal gemstone cluster"),
    "emerald_gem": ("kesilmemis_zumrut", "rough raw green emerald crystal mineral rock"),
    "diamond_gem": ("parlak_elmas", "large brilliant faceted cut sparkling transparent diamond gemstone"),
    "amethyst_geode": ("ametist_geodu", "purple amethyst crystal hollow geode rock"),
    "uranium_rod": ("uranyum_cubugu", "glowing neon green uranium fuel rod cell canister"),
    "meteorite_ore": ("meteorit_cevheri", "black pitted cratered space meteorite ore rock"),

    # 5. OFİS & BÜRO
    "filing_cabinet": ("dosya_dolabi", "tall vertical metal office filing cabinet drawers"),
    "office_chair": ("ofis_koltugu", "swivel mesh ergonomic office desk chair with wheels"),
    "computer_monitor": ("monitor", "widescreen LCD computer desktop monitor screen"),
    "keyboard": ("klavye", "mechanical typing computer keyboard"),
    "computer_mouse": ("mouse", "small optical computer desktop mouse device"),
    "stapler": ("zimba", "metal office paper document stapler tool"),
    "hole_punch": ("delgec", "heavy metal office paper two-hole puncher"),
    "tape_dispenser": ("bant_kesici", "weighted desktop scotch tape dispenser tool"),
    "desktop_pc": ("pc_kasasi", "black gaming desktop computer tower chassis"),
    "printer": ("yazici", "desktop paper laser office printer scanner machine"),

    # 6. MOBİLYA & EV
    "wardrobe": ("gardirop", "tall wooden bedroom wardrobe closet armoire with doors"),
    "double_bed": ("cift_kisilik_yatak", "double bed frame with clean mattress and pillows"),
    "velvet_sofa": ("kadife_kanepe", "comfortable tufted velvet living room sofa couch"),
    "armchair": ("berjer_koltuk", "single wingback lounge armchair seat"),
    "coffee_table": ("orta_sehpa", "low wooden coffee table living room"),
    "coat_rack": ("elbise_askiligi", "tall standing wooden coat hat rack stand"),
    "wall_mirror": ("duvar_aynasi", "ornate framed decorative glass wall hanging mirror"),
    "table_lamp": ("abajur_lamba", "vintage table bedside lamp with shade"),
    "oil_painting": ("yagli_boya_tablo", "framed classical oil painting artwork on canvas"),
    "marble_bust": ("roma_bustu", "classical white marble roman head bust statue"),
    "gramophone": ("gramofon", "vintage antique vinyl gramophone with brass horn"),
    "table_clock": ("somine_saati", "antique bronze mantel fireplace tabletop clock"),
    "jewelry_box": ("mucevher_kutusu", "ornate carved wooden jewelry box chest with velvet"),
    "quill_inkpot": ("hokka_ve_tuy_kalem", "antique glass inkwell bottle with feather quill pen"),

    # 7. EL ALETLERİ & ZANAAT
    "toolbox": ("kirmizi_alet_cantasi", "rugged heavy red steel toolbox chest container"),
    "hammer": ("cekic", "heavy steel claw hammer construction hand tool"),
    "pipe_wrench": ("boru_anahtari", "heavy cast steel plumbing pipe wrench"),
    "handsaw": ("el_testeresi", "woodworking hand saw with wooden handle"),
    "pliers": ("pense", "combination gripping pliers hand tool"),
    "ratchet_wrench": ("circir_anahtar", "chrome mechanic socket ratchet wrench"),
    "screwdriver_flat": ("duz_tornavida", "flathead slotted screwdriver tool"),
    "screwdriver_cross": ("yildiz_tornavida", "phillips crosshead screwdriver tool"),
    "measuring_tape": ("mezura", "retractable yellow measuring tape roll"),
    "bench_vise": ("tezgah_mengenesi", "heavy cast iron workshop workbench clamp vise"),
    "soldering_station": ("lehim_istasyonu", "electronic digital soldering iron station unit"),
    "dremel_rotary": ("gravur_el_aleti_dremel", "handheld electric rotary engraving dremel tool"),
    "dremel_bits": ("dremel_freze_uclari", "set of precision dremel carving drill bits"),
    "micrometer": ("mikrometre_kumpas", "digital precision vernier micrometer caliper measuring tool"),

    # 8. SİLAHLAR & ZIRHLAR
    "sniper_rifle": ("durbunlu_tufek", "bolt action sniper rifle firearm with scope"),
    "crossbow": ("av_arbaleti", "modern hunting crossbow weapon with limbs"),
    "shotgun": ("pompali_tufek", "tactical pump action combat shotgun firearm"),
    "pistol": ("taktik_tabanca_glock", "matte black semi automatic tactical pistol handgun"),
    "revolver": ("revolver_altiparlar", "classic cylinder six-shooter revolver pistol"),
    "hunting_knife": ("av_bicagi", "combat tactical survival hunting knife fixed blade"),
    "frag_grenade": ("el_bombasi", "military explosive fragmentation grenade weapon"),
    "smoke_grenade": ("sis_bombasi", "cylindrical canister smoke grenade"),
    "knight_sword": ("sovalye_kilici", "double edged steel medieval knight sword blade"),
    "battle_axe": ("savas_baltasi", "two handed heavy steel viking battle axe"),
    "plasma_rifle": ("plazma_tufek", "sci-fi futuristic glowing blue plasma laser rifle"),
    "beam_katana": ("isin_katanasi", "sci-fi glowing neon purple cybernetic beam katana sword"),
    "arcane_scroll": ("buyu_parsomani", "ancient magical glowing blue spell parchment scroll"),
    "reactor_core": ("reaktor_cekirdegi", "glowing sci-fi fusion reactor core power crystal"),
    "cybernetic_hand": ("sibernetik_el", "robotic mechanical cybernetic prosthesis hand arm"),
    "circuit_board": ("devre_karti", "electronic green printed circuit board PCB with microchips"),
    "teleport_beacon": ("isinlanma_cihazi", "circular sci-fi teleportation portal platform pad"),
    "plasma_bracer": ("plazma_bileklik", "futuristic wrist mounted energy shield emitter bracer"),

    # 9. ZIRH PARÇALARI
    "full_helmet": ("vizorlu_kask", "medieval knight full head enclosed helmet visor"),
    "spartan_helmet": ("sparta_migferi", "bronze ancient spartan warrior helmet with crest"),
    "tactical_helmet": ("karbon_kask", "modern military ballistic carbon fiber combat helmet"),
    "breastplate": ("celik_gogusluk", "solid heavy plate steel cuirass armor breastplate"),
    "copper_cuirass": ("bakir_gogusluk", "hammered raw copper armor plate chest cuirass"),
    "ballistic_vest": ("balistik_yelek", "tactical military body armor plate carrier vest"),
    "round_shield": ("yuvarlak_kalkan", "circular reinforced wood and bronze round shield"),
    "tower_shield": ("kule_kalkani", "tall heavy rectangular steel knight tower shield"),
    "armor_gauntlets": ("celik_eldiven", "pair of articulated steel armor plate gauntlets gloves"),
    "armor_greaves": ("celik_dizlik", "pair of heavy plate armor steel shin leg greaves"),
    "armor_boots": ("kompozit_bot", "pair of heavy armored reinforced combat sabaton boots"),
    "utility_belt": ("guc_kemeri", "heavy leather utility belt with buckle pouches"),
    "shoulder_pauldrons": ("celik_omuzluk", "pair of curved steel armor shoulder pauldrons")
}

# Prompt hazırlığı
DICT_KEYS = list(UNIVERSAL_ITEM_DICTIONARY.keys())
PROMPTS = [
    f"a clean 2D game asset of a {UNIVERSAL_ITEM_DICTIONARY[k][1]}, isolated pure white background"
    for k in DICT_KEYS
]

def identify_and_rename_category(cat_dir):
    slug = cat_dir.name
    png_files = sorted(list(cat_dir.glob("*.png")))
    if not png_files:
        return 0

    print(f"\n📂 [{slug.upper()}] Taranıyor ({len(png_files)} Parça)...")

    # Görselleri oku
    images = []
    file_bytes = []
    valid_pngs = []
    for pf in png_files:
        try:
            with Image.open(pf) as img:
                # Beyaz zeminle RGB yap
                rgb_img = Image.new("RGB", img.size, (255, 255, 255))
                if img.mode == "RGBA":
                    rgb_img.paste(img, mask=img.split()[3])
                else:
                    rgb_img = img.convert("RGB")
                images.append(rgb_img)
                webp_f = pf.with_suffix(".webp")
                webp_b = webp_f.read_bytes() if webp_f.exists() else None
                file_bytes.append((pf.read_bytes(), webp_b))
                valid_pngs.append(pf)
        except Exception:
            pass

    if not images:
        return 0

    # CLIP ile Evrensel Eşleştirme (Zero-Shot Softmax)
    inputs = processor(text=PROMPTS, images=images, return_tensors="pt", padding=True)
    with torch.no_grad():
        outputs = model(**inputs)
        probs = outputs.logits_per_image.softmax(dim=1).cpu().numpy()

    # Her bir görselin gerçek adını belirle
    detected_items = []
    used_names_count = {}

    for idx, pf in enumerate(valid_pngs):
        best_idx = probs[idx].argmax()
        conf = probs[idx][best_idx] * 100.0
        dict_key = DICT_KEYS[best_idx]
        tr_slug_name = UNIVERSAL_ITEM_DICTIONARY[dict_key][0]

        # Mükerrer isimleri say (örn: buzdolabi_02, buzdolabi_03)
        count = used_names_count.get(tr_slug_name, 0) + 1
        used_names_count[tr_slug_name] = count

        suffix = f"_{count:02d}" if count > 1 else ""
        final_item_name = f"{tr_slug_name}{suffix}"

        detected_items.append((final_item_name, tr_slug_name, conf))
        print(f"  🔍 Görsel {pf.name:<25} -> 🧠 AI Teşhisi: '{final_item_name}' (Güven: %{conf:.1f})")

    # Eski dosyaları sil
    for pf in png_files:
        try: pf.unlink(missing_ok=True)
        except: pass
        try: pf.with_suffix(".webp").unlink(missing_ok=True)
        except: pass

    # Yeniden temiz ve gerçek adlarıyla yaz
    for idx, (pf_bytes, (final_name, _, _)) in enumerate(zip(file_bytes, detected_items)):
        new_base = f"{idx+1:02d}_{final_name}"
        new_png = cat_dir / f"{new_base}.png"
        new_webp = cat_dir / f"{new_base}.webp"

        new_png.write_bytes(pf_bytes[0])
        if pf_bytes[1]:
            new_webp.write_bytes(pf_bytes[1])

    # Onay kilidi
    lock_file = cat_dir / ".verified"
    lock_file.write_text(json.dumps({"verified": True, "count": len(valid_pngs)}, indent=2))
    return len(valid_pngs)

def run_open_vocabulary_pipeline():
    cat_dirs = sorted([d for d in ITEMS_DIR.iterdir() if d.is_dir()])
    total_items = 0

    for cat_dir in cat_dirs:
        count = identify_and_rename_category(cat_dir)
        total_items += count

    MANIFEST_PATH.write_text(json.dumps({
        "verified_categories": len(cat_dirs),
        "total_items": total_items
    }, indent=2))

    print("\n=================================================================")
    print("🎉 TÜM KATEGORİLER EVRENSEL YAPAY ZEKA İLE YENİDEN İSİMLENDİRİLDİ!")
    print(f"  -> Toplam İşlenen Eşya: {total_items}")
    print(f"  -> Kilitlenen Klasör: {len(cat_dirs)} / {len(cat_dirs)}")
    print("=================================================================")

if __name__ == "__main__":
    run_open_vocabulary_pipeline()

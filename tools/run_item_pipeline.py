import sys
import shutil
import subprocess
from pathlib import Path

def main():
    print("========================================================")
    print(">> OYUN ESYA URETIM, AYIKLAMA VE KATALOG PIPELINE'I")
    print("========================================================")
    
    root_dir = Path(r"d:\github\depo")
    raw_dir = root_dir / "assets" / "raw_input"
    raw_dir.mkdir(parents=True, exist_ok=True)

    brain_dir = Path(r"C:\Users\ismai\.gemini\antigravity-ide\brain\9aa163c3-b05b-4a95-85fb-c3a84517d898")
    
    files_to_copy = [
        ("mutfak_gastronomi_grid_1788862623473.jpg", "23_mutfak_gastronomi.jpg"),
        ("kilit_hirsizlik_grid_1788862644994.jpg", "24_kilit_ve_hirsizlik.jpg"),
        ("tip_saglik_grid_1788862672090.jpg", "25_tip_ve_saglik.jpg"),
        ("denizcilik_balikcilik_grid_1788865862718.jpg", "26_denizcilik_ve_balikcilik.jpg"),
        ("arkeoloji_antik_kalintilar_grid_1788865879977.jpg", "27_arkeoloji_ve_antik_kalintilar.jpg"),
        ("tarim_bahce_ekipmanlari_grid_1788865898264.jpg", "28_tarim_ve_bahce_ekipmanlari.jpg"),
    ]
    
    print("\n1. Ham gorseller raw_input klasorune kopyalaniyor...")
    copied_count = 0
    for src_name, dst_name in files_to_copy:
        src_path = brain_dir / src_name
        dst_path = raw_dir / dst_name
        if src_path.exists():
            shutil.copy2(src_path, dst_path)
            print(f"   [+] Kopyalandi: {dst_name}")
            copied_count += 1
        else:
            print(f"   [!] Bulunamadi: {src_path}")
            
    print(f">> Toplam {copied_count} gorsel hazirlandi.")

    # 2. Ayiklama
    print("\n2. Esyalar ayiklaniyor ve seffaf PNG/WebP olarak kaydediliyor...")
    ayiklama_script = root_dir / "tools" / "item_ayiklama.py"
    res1 = subprocess.run([sys.executable, str(ayiklama_script)], cwd=str(root_dir))
    if res1.returncode != 0:
        print("[!] item_ayiklama.py calisirken bir hata olustu.")
        return

    # 3. Katalog Guncelleme
    print("\n3. Esya katalogu (default_items.json) taranip guncelleniyor...")
    catalog_script = root_dir / "tools" / "build_all_items_catalog.py"
    res2 = subprocess.run([sys.executable, str(catalog_script)], cwd=str(root_dir))
    if res2.returncode != 0:
        print("[!] build_all_items_catalog.py calisirken bir hata olustu.")
        return

    print("\n========================================================")
    print(">> TUM ISLEMLER BASARIYLA TAMAMLANDI!")
    print("========================================================")

if __name__ == "__main__":
    main()

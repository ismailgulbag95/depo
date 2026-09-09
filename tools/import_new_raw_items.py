import os
import shutil
from pathlib import Path

CURR_BRAIN_DIR = Path(r"C:\Users\ismai\.gemini\antigravity-ide\brain\9aa163c3-b05b-4a95-85fb-c3a84517d898")
PROJECT_ROOT = Path(r"d:\github\depo")
RAW_INPUT_DIR = PROJECT_ROOT / "assets" / "raw_input"

MAPPINGS = {
    "mutfak_gastronomi_grid_1788862623473.jpg": "23_mutfak_gastronomi.jpg",
    "kilit_hirsizlik_grid_1788862644994.jpg": "24_kilit_ve_hirsizlik.jpg",
    "tip_saglik_grid_1788862672090.jpg": "25_tip_ve_saglik.jpg",
}

def main():
    RAW_INPUT_DIR.mkdir(parents=True, exist_ok=True)
    for src_name, dst_name in MAPPINGS.items():
        src_path = CURR_BRAIN_DIR / src_name
        dst_path = RAW_INPUT_DIR / dst_name
        if src_path.exists():
            shutil.copy2(src_path, dst_path)
            print(f"✅ Kopyalandı: {dst_name} ({src_path.stat().st_size} bytes)")
        else:
            print(f"❌ Kaynak bulunamadı: {src_path}")

if __name__ == "__main__":
    main()

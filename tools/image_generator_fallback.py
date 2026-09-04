import os
import sys
import argparse
import urllib.parse
import requests

def generate_image(prompt: str, output_path: str, width: int = 1024, height: int = 1024, model: str = "flux") -> bool:
    """
    Pollinations AI üzerinden prompt ile görsel üretir ve hedef yola kaydeder.
    """
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    encoded_prompt = urllib.parse.quote(prompt)
    url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width={width}&height={height}&nologo=true&model={model}"

    print(f"🎨 Üretim Başlatıldı: {os.path.basename(output_path)}")
    print(f"📝 Prompt: {prompt}")
    print(f"🔗 URL: {url}")

    try:
        response = requests.get(url, timeout=90)
        if response.status_code == 200:
            with open(output_path, "wb") as f:
                f.write(response.content)
            size_kb = round(os.path.getsize(output_path) / 1024, 1)
            print(f"✅ Başarıyla üretildi ve kaydedildi: {output_path} ({size_kb} KB)")
            return True
        else:
            print(f"❌ API Hatası ({response.status_code}): {response.text[:120]}")
            return False
    except Exception as err:
        print(f"❌ Bağlantı hatası: {err}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Pollinations AI Görsel Üretim Aracı (Gemini Fallback Motoru)")
    parser.add_argument("--prompt", "-p", required=True, help="Görsel üretim promptu")
    parser.add_argument("--output", "-o", required=True, help="Kaydedilecek dosya yolu (ör: assets/vehicles/bagaj.png)")
    parser.add_argument("--width", "-W", type=int, default=1024, help="Genişlik (varsayılan: 1024)")
    parser.add_argument("--height", "-H", type=int, default=1024, help="Yükseklik (varsayılan: 1024)")
    parser.add_argument("--model", "-m", default="flux", help="Model adı (varsayılan: flux)")

    args = parser.parse_args()
    success = generate_image(
        prompt=args.prompt,
        output_path=args.output,
        width=args.width,
        height=args.height,
        model=args.model
    )
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

import os
import shutil

BRAIN_DIR = r"C:\Users\ismai\.gemini\antigravity-ide\brain\1f78ed8c-6d6b-47a6-b83d-5f60a5878aa6"
ASSETS_DIR = r"d:\github\depo\assets"

ASSET_MAPPING = {
    # Characters (Auction & Rivals)
    "auctioneer_dan_1788557715507.jpg": os.path.join(ASSETS_DIR, "characters", "auctioneer_dan.jpg"),
    "rival_dave_1788557733470.jpg": os.path.join(ASSETS_DIR, "characters", "rival_dave.jpg"),
    "rival_laura_1788557754375.jpg": os.path.join(ASSETS_DIR, "characters", "rival_laura.jpg"),
    "rival_gus_1788557779991.jpg": os.path.join(ASSETS_DIR, "characters", "rival_gus.jpg"),

    # Vehicles & Trunks
    "trunk_pickup_1788557888421.jpg": os.path.join(ASSETS_DIR, "vehicles", "trunk_pickup.jpg"),
    "trunk_van_1788557909770.jpg": os.path.join(ASSETS_DIR, "vehicles", "trunk_van.jpg"),
    "trunk_truck_1788557933318.jpg": os.path.join(ASSETS_DIR, "vehicles", "trunk_truck.jpg"),
    "vehicle_emergency_tow_1788557957892.jpg": os.path.join(ASSETS_DIR, "vehicles", "vehicle_emergency_tow.jpg"),

    # Backgrounds
    "bg_auction_yard_1788558016974.jpg": os.path.join(ASSETS_DIR, "backgrounds", "bg_auction_yard.jpg"),
    "bg_workshop_garage_1788558044053.jpg": os.path.join(ASSETS_DIR, "backgrounds", "bg_workshop_garage.jpg"),
    "bg_marketplace_store_1788558075481.jpg": os.path.join(ASSETS_DIR, "backgrounds", "bg_marketplace_store.jpg"),

    # Customers
    "customer_bob_1788558201556.jpg": os.path.join(ASSETS_DIR, "characters", "customer_bob.jpg"),
    "customer_victoria_1788558236617.jpg": os.path.join(ASSETS_DIR, "characters", "customer_victoria.jpg"),
}

def main():
    print("🚀 Görsel varlıklar kopyalanıyor...")
    for src_name, dst_path in ASSET_MAPPING.items():
        src_path = os.path.join(BRAIN_DIR, src_name)
        if os.path.exists(src_path):
            os.makedirs(os.path.dirname(dst_path), exist_ok=True)
            shutil.copy2(src_path, dst_path)
            print(f"✅ Kopyalandı: {os.path.basename(dst_path)}")
        else:
            print(f"⚠️ Bulunamadı: {src_name}")
    print("🎉 Tüm görsel varlıklar assets/ altına başarıyla yerleştirildi!")

if __name__ == "__main__":
    main()

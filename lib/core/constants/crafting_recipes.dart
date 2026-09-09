import 'package:yeni_oyun_sablon/core/database/models/crafting_recipe_model.dart';

/// Oyunun 5 Kat Genişletilmiş, Çok Kademeli Üretim, Montaj ve Demontaj Reçeteleri Kataloğu (35 Reçete)
class GameCraftingRecipes {
  static const List<CraftingRecipeModel> all = [
    // =========================================================================
    // 1. DEMONTAJ, HURDALAMA & PARÇA SÖKÜMÜ (SALVAGE / RECYCLING - 10 REÇETE)
    // =========================================================================
    CraftingRecipeModel(
      id: 'salvage_broken_drill',
      titleTr: 'Arızalı Matkabı Parçala & Motorunu Sök',
      titleEn: 'Disassemble Faulty Drill for Electric Motor',
      descriptionTr: 'Yanık gövdeyi sökerek içindeki bakır sarımlı elektrik motorunu ve bataryayı kurtarın.',
      descriptionEn: 'Strip the burnt casing to salvage the copper-wound electric motor and lithium cells.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 1,
      requiredToolCategory: 'manuel_el_aletleri',
      inputs: [
        RecipeItemRequirement(itemCode: 'hurda_kirik_matkap', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_elektrik_motoru', count: 1),
        RecipeItemRequirement(itemCode: 'elektronik_aletler_batarya', count: 1),
      ],
      cashCost: 20,
      rewardXp: 35,
    ),

    CraftingRecipeModel(
      id: 'salvage_v8_engine',
      titleTr: 'V8 Motor Bloğunu Bileşenlerine Ayır',
      titleEn: 'Tear Down V8 Engine Block',
      descriptionTr: 'Ağır motor bloğunu sökerek sağlam bujileri, dinamo jeneratörünü ve manifoldu ayıklayın.',
      descriptionEn: 'Strip down the heavy block to recover pristine spark plugs, alternator dynamo and manifold.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 2,
      requiredToolCategory: 'manuel_el_aletleri',
      inputs: [
        RecipeItemRequirement(itemCode: 'araba_parcalari_v8_motor_blogu', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'araba_parcalari_buji', count: 2),
        RecipeItemRequirement(itemCode: 'agir_sanayi_dinamo', count: 1),
        RecipeItemRequirement(itemCode: 'araba_parcalari_egzoz_manifoldu', count: 1),
      ],
      cashCost: 80,
      rewardXp: 90,
    ),

    CraftingRecipeModel(
      id: 'salvage_cracked_rim',
      titleTr: 'Çatlak Janttan Titanyum & Metal Külçe Çıkar',
      titleEn: 'Melt & Extract Metal from Cracked Rim',
      descriptionTr: 'Hasarlı alaşım jantı tezgâhta kesip eriterek saf titanyum külçesine dönüştürün.',
      descriptionEn: 'Cut and mill the damaged alloy rim into refined industrial titanium block.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'hurda_ezik_aluminyum_jant', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_titanyum_blok', count: 1),
      ],
      cashCost: 50,
      rewardXp: 50,
    ),

    CraftingRecipeModel(
      id: 'salvage_burnt_guitar_amp',
      titleTr: 'Yanık Amfiden Devre Kartı & Trafo Kurtar',
      titleEn: 'Scrap Burnt Guitar Amp for Circuit Boards',
      descriptionTr: 'Yanmış gitar amfisini sökerek elektronik devre kartını ve trafo bileşenlerini ayıklayın.',
      descriptionEn: 'Tear down the damaged amplifier chassis to salvage copper transformer and circuits.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 1,
      inputs: [
        RecipeItemRequirement(itemCode: 'hurda_bozuk_amfi', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_devre_karti', count: 1),
        RecipeItemRequirement(itemCode: 'elektronik_aletler_taslama_anahtari', count: 1),
      ],
      cashCost: 30,
      rewardXp: 40,
    ),

    CraftingRecipeModel(
      id: 'salvage_rusty_extinguisher',
      titleTr: 'Paslı Yangın Tüpünden Basınç Vanası Sök',
      titleEn: 'Dismantle Fire Extinguisher for Manometer',
      descriptionTr: 'Basıncı boşalmış yangın tüpünün pirinç nozülünü ve hassas manometresini sökün.',
      descriptionEn: 'Safely unthread the brass nozzle to extract the industrial pressure manometer.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 1,
      inputs: [
        RecipeItemRequirement(itemCode: 'hurda_eski_yangin_tupu', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_manometre', count: 1),
      ],
      cashCost: 15,
      rewardXp: 30,
    ),

    CraftingRecipeModel(
      id: 'salvage_crt_television',
      titleTr: 'Tüplü TV Katot Işın Tüpü & Şasi Sökümü',
      titleEn: 'Discharge & Teardown CRT Television',
      descriptionTr: 'Antika tüplü televizyonun bakır sargılı saptırma bobinlerini ve anakartını kurtarın.',
      descriptionEn: 'Carefully discharge and dismantle CRT display for thick copper coils and motherboard.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'beyaz_esya_tuplu_tv', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_devre_karti', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_salter_kutusu', count: 1),
      ],
      cashCost: 45,
      rewardXp: 60,
    ),

    CraftingRecipeModel(
      id: 'salvage_washing_machine',
      titleTr: 'Çamaşır Makinesi Motoru & Amortisör Sökümü',
      titleEn: 'Strip Washing Machine Motor & Shocks',
      descriptionTr: 'Ağır çamaşır makinesini parçalayarak güçlü asenkron motorunu ve şok emicilerini ayırın.',
      descriptionEn: 'Strip heavy domestic washer to obtain induction motor and heavy coilover shocks.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'beyaz_esya_camasir_makinesi', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_elektrik_motoru', count: 1),
        RecipeItemRequirement(itemCode: 'araba_parcalari_amortisor', count: 1),
      ],
      cashCost: 60,
      rewardXp: 70,
    ),

    CraftingRecipeModel(
      id: 'salvage_retro_refrigerator',
      titleTr: 'Retro Buzdolabından Kompresör & Bakır Boru Sök',
      titleEn: 'Salvage Copper Lines & Compressor from Fridge',
      descriptionTr: 'Eski buzdolabının arkasındaki saf bakır radyatör borularını ve motorunu kurtarın.',
      descriptionEn: 'Reclaim high-purity copper tubing and heavy cast condenser pump from retro fridge.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'beyaz_esya_retro_buzdolabi', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_bakir_kulce', count: 2),
        RecipeItemRequirement(itemCode: 'agir_sanayi_elektrik_motoru', count: 1),
      ],
      cashCost: 75,
      rewardXp: 80,
    ),

    CraftingRecipeModel(
      id: 'salvage_pc_tower',
      titleTr: 'Hurda PC Kasasından Güç Kaynağı & Kart Sök',
      titleEn: 'Dismantle PC Tower for Power Supply & Boards',
      descriptionTr: 'Masaüstü bilgisayar kasasını açarak güç besleme trafosunu ve fanları ayıklayın.',
      descriptionEn: 'Open up the desktop PC to salvage switching power supply and circuit boards.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 1,
      inputs: [
        RecipeItemRequirement(itemCode: 'ofis_ekipmanlari_pc_kasasi', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_devre_karti', count: 2),
        RecipeItemRequirement(itemCode: 'beyaz_esya_vantilator', count: 1),
      ],
      cashCost: 35,
      rewardXp: 50,
    ),

    CraftingRecipeModel(
      id: 'salvage_broken_generator',
      titleTr: 'Endüstriyel Dinamodan Bakır Sargıları Ayır',
      titleEn: 'Extract Pure Copper Windings from Dynamo',
      descriptionTr: 'Hasarlı dinamo jeneratörünü hidrolik tezgahta açarak saf bakır külçesi elde edin.',
      descriptionEn: 'Crack open the heavy alternator core to extract dense refined copper blocks.',
      type: RecipeType.salvage,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_dinamo', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_bakir_kulce', count: 3),
        RecipeItemRequirement(itemCode: 'agir_sanayi_guc_kemeri', count: 1),
      ],
      cashCost: 90,
      rewardXp: 100,
    ),

    // =========================================================================
    // 2. AĞIR MEKANİK, MOTOR & SANAYİ MONTAJI (7 REÇETE)
    // =========================================================================
    CraftingRecipeModel(
      id: 'craft_master_mechanic_kit',
      titleTr: 'Tam Donanımlı Usta Takım Sandığı Üret',
      titleEn: 'Assemble Master Mechanic Tool Chest',
      descriptionTr: 'Kırmızı alet çantasını lokma seti, ayarlı anahtar ve cırcır ile birleştirip profesyonel takım sandığına dönüştürün.',
      descriptionEn: 'Equip red metal toolbox with complete socket set, wrench and ratchet into an elite master tool chest.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'manuel_el_aletleri_kirmizi_alet_cantasi', count: 1),
        RecipeItemRequirement(itemCode: 'manuel_el_aletleri_lokma_seti', count: 1),
        RecipeItemRequirement(itemCode: 'manuel_el_aletleri_circir_anahtar', count: 1),
        RecipeItemRequirement(itemCode: 'manuel_el_aletleri_buyuk_ayarli_anahtar', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_tezgah_mengenesi', count: 1),
      ],
      cashCost: 120,
      rewardXp: 130,
    ),

    CraftingRecipeModel(
      id: 'craft_v8_twin_turbo_engine',
      titleTr: 'V8 Çift Turbo Drag Yarış Motoru Montajı',
      titleEn: 'Assemble V8 Twin-Turbo Race Engine',
      descriptionTr: 'V8 motor bloğuna çift turboşarj, bujiler ve egzoz manifoldu monte ederek 900 beygirlik yarış motoru üretin.',
      descriptionEn: 'Bolt dual turbochargers and high-flow exhaust manifolds onto V8 engine block for maximum horsepower.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 4,
      inputs: [
        RecipeItemRequirement(itemCode: 'araba_parcalari_v8_motor_blogu', count: 1),
        RecipeItemRequirement(itemCode: 'araba_parcalari_turbosarj', count: 1),
        RecipeItemRequirement(itemCode: 'araba_parcalari_buji', count: 2),
        RecipeItemRequirement(itemCode: 'araba_parcalari_egzoz_manifoldu', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'araba_parcalari_yaris_koltugu', count: 1),
      ],
      cashCost: 350,
      rewardXp: 280,
    ),

    CraftingRecipeModel(
      id: 'craft_hydraulic_press',
      titleTr: 'Yüksek Basınçlı Endüstriyel Hidrolik Pres',
      titleEn: 'Fabricate Heavy Hydraulic Press Machine',
      descriptionTr: 'Hidrolik piston, çelik boru dirseği, buhar vanası ve manometreyi tezgâha bağlayarak pres inşa edin.',
      descriptionEn: 'Combine hydraulic cylinder, pipe elbow, steam valve and pressure manometer into a stamping press.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_hidrolik_piston', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_buhar_vanasi', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_boru_dirsegi', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_manometre', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_disli_cark', count: 1),
      ],
      cashCost: 220,
      rewardXp: 210,
    ),

    CraftingRecipeModel(
      id: 'craft_power_generator_station',
      titleTr: 'Ağır Sanayi Elektrik Jeneratör İstasyonu',
      titleEn: 'Construct Heavy Industrial Generator Station',
      descriptionTr: 'Elektrik motoru, dinamo, şalter kutusu ve güç aktarım kayışını birleştirerek otonom jeneratör kurun.',
      descriptionEn: 'Wire motor, alternator dynamo, power belt and electrical switch box into a diesel power plant.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_elektrik_motoru', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_dinamo', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_salter_kutusu', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_guc_kemeri', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'elektronik_aletler_taslama_makinesi', count: 1),
      ],
      cashCost: 190,
      rewardXp: 180,
    ),

    CraftingRecipeModel(
      id: 'craft_competition_brake_suspension',
      titleTr: 'Yarış Süspansiyonu & Kaliperli Fren Kiti',
      titleEn: 'Build Track Coilovers & Caliper Brake Kit',
      descriptionTr: 'Yüksek dirençli amortisör, fren diski ve alaşım jantı kalibre ederek pist süspansiyon kiti hazırlayın.',
      descriptionEn: 'Calibrate high-spec shock absorbers with ventilated brake discs and alloy wheel rims.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'araba_parcalari_amortisor', count: 1),
        RecipeItemRequirement(itemCode: 'araba_parcalari_fren_diski', count: 1),
        RecipeItemRequirement(itemCode: 'araba_parcalari_alasim_jant', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'araba_parcalari_spor_direksiyon', count: 1),
      ],
      cashCost: 160,
      rewardXp: 150,
    ),

    CraftingRecipeModel(
      id: 'craft_lathe_station',
      titleTr: 'Minyatür Hassas Metal Torna Tezgahı',
      titleEn: 'Miniature Precision Metal Lathe Station',
      descriptionTr: 'Torna aynası, dremel freze ucu, tezgah mengenesi ve dijital kumpas ile hassas torna tezgahı üretin.',
      descriptionEn: 'Mount miniature chuck, rotary carving tool and digital micrometer to build a precision lathe.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_torna_aynasi', count: 1),
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_tezgah_mengenesi', count: 1),
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_mikrometre_kumpas', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_lehim_istasyonu', count: 1),
      ],
      cashCost: 180,
      rewardXp: 170,
    ),

    CraftingRecipeModel(
      id: 'craft_industrial_crane_hoist',
      titleTr: 'Ağır Yük Vinç & Çelik Kanca Düzeneği',
      titleEn: 'Heavy Industrial Crane & Hoist System',
      descriptionTr: 'Döküm vinç zinciri, dişli çark ve çelik tel kancayı birleştirerek tonluk yükleri kaldıracak vinç yapın.',
      descriptionEn: 'Rig forged hoist chain, heavy gear cog and steel grappling cable into an overhead gantry crane.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_vinc_zinciri', count: 1),
        RecipeItemRequirement(itemCode: 'agir_sanayi_disli_cark', count: 1),
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_celik_tel_kanca', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'agir_sanayi_hidrolik_piston', count: 1),
      ],
      cashCost: 210,
      rewardXp: 200,
    ),

    // =========================================================================
    // 3. CASUSLUK, KİLİT AÇMA & ELEKTRONİK SENTEZİ (7 REÇETE)
    // =========================================================================
    CraftingRecipeModel(
      id: 'craft_covert_heist_rig',
      titleTr: 'Profesyonel Çilingir Kasa Açma Düzeneği',
      titleEn: 'Assemble Covert Safe-Cracking Rig',
      descriptionTr: 'Maymuncuk seti, kasa stetoskobu ve UV feneri birleştirerek tüm gizli kasaları açan bir kit üretin.',
      descriptionEn: 'Combine lockpick set, medical stethoscope and UV light to assemble an elite safe-cracking rig.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_deri_kilifli_maymuncuk_seti', count: 1),
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_kasa_stetoskobu', count: 1),
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_uv_mor_otesisi_fener', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_sifre_kirici_dekoder', count: 1),
      ],
      cashCost: 200,
      rewardXp: 190,
    ),

    CraftingRecipeModel(
      id: 'craft_silent_entry_kit',
      titleTr: 'Sessiz Giriş & Cam Kesme Tertibatı',
      titleEn: 'Silent Infiltration & Glass Cutter Rig',
      descriptionTr: 'Vakumlu cam kesici, sessiz akülü matkap ve çelik tel kancayı bir araya getiren casus giriş kiti.',
      descriptionEn: 'Pair suction cup circular glass cutter with quiet carbon drill and climbing hook.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_cam_vantuzlu_kesici', count: 1),
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_sessiz_akulu_matkap', count: 1),
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_celik_tel_kanca', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_deri_kilifli_maymuncuk_seti', count: 1),
      ],
      cashCost: 230,
      rewardXp: 210,
    ),

    CraftingRecipeModel(
      id: 'craft_frequency_decoder_device',
      titleTr: 'Dijital Frekans Bypass & Elektronik Dekoder',
      titleEn: 'Digital Frequency Cipher Bypass Decoder',
      descriptionTr: 'Elektronik devre kartı, multimetre ve telsiz alıcısını senkronize ederek şifre çözücü üretin.',
      descriptionEn: 'Wire printed circuit board, digital multimeter and tactical radio receiver into a decoder device.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 4,
      inputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_devre_karti', count: 1),
        RecipeItemRequirement(itemCode: 'elektronik_aletler_multimetre', count: 1),
        RecipeItemRequirement(itemCode: 'taktik_hayatta_kalma_telsiz', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_sifre_kirici_dekoder', count: 1),
      ],
      cashCost: 310,
      rewardXp: 290,
    ),

    CraftingRecipeModel(
      id: 'craft_tactical_smoke_breach',
      titleTr: 'Taktik Sis Bombası & Görüş Kapatıcı Kapsül',
      titleEn: 'Assemble Tactical Smoke Grenade Canister',
      descriptionTr: 'Boş yangın tüpü gövdesine kimyasal asit şişesi ve fitil monte ederek yoğun sis bombası üretin.',
      descriptionEn: 'Fill depressurized cylinder with chemical reagent bottles to formulate tactical dense smoke screen.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'hurda_eski_yangin_tupu', count: 1),
        RecipeItemRequirement(itemCode: 'laboratuvar_simya_erlenmayer', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_sis_bombasi', count: 1),
      ],
      cashCost: 80,
      rewardXp: 90,
    ),

    CraftingRecipeModel(
      id: 'craft_forensic_investigator_light',
      titleTr: 'Kriminal Parmak İzi & UV Muayene Feneri',
      titleEn: 'Forensic Ultraviolet Searchlight Rig',
      descriptionTr: 'LED el fenerine otoskop optik merceği ve UV filtresi takarak kriminal inceleme feneri yapın.',
      descriptionEn: 'Mount otoscope clinical optic lens and UV filter glass onto tactical LED flashlight body.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'taktik_hayatta_kalma_el_feneri', count: 1),
        RecipeItemRequirement(itemCode: 'tip_ve_saglik_otoskop_muayene_feneri', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_uv_mor_otesisi_fener', count: 1),
      ],
      cashCost: 75,
      rewardXp: 85,
    ),

    CraftingRecipeModel(
      id: 'craft_portable_smd_soldering_kit',
      titleTr: 'Taşınabilir Hassas SMD Lehimleme İstasyonu',
      titleEn: 'Field Portable SMD Soldering Station',
      descriptionTr: 'Lehim istasyonunu sıcak hava tabancası ve lityum batarya ile portatif sahaya uyarlayın.',
      descriptionEn: 'Convert bench soldering station into cordless mobile unit using heat gun and power battery.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_lehim_istasyonu', count: 1),
        RecipeItemRequirement(itemCode: 'elektronik_aletler_sicak_hava_tabancasi', count: 1),
        RecipeItemRequirement(itemCode: 'elektronik_aletler_batarya', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'elektronik_aletler_darbeli_matkap', count: 1),
      ],
      cashCost: 150,
      rewardXp: 140,
    ),

    CraftingRecipeModel(
      id: 'craft_infiltrator_identity_wallet',
      titleTr: 'Gizli Bölmeli Diplomatik Kimlik Cüzdanı',
      titleEn: 'Concealed Compartment Diplomatic ID Wallet',
      descriptionTr: 'Deri cüzdanın astarına ince çelik maymuncuk bıçağı ve sahte diplomat rozeti gizleyin.',
      descriptionEn: 'Conceal micro pick-blades and forged metallic credentials inside heavy leather pocket.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_sahte_kimlik_cuzdani', count: 1),
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_deri_kilifli_maymuncuk_seti', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'kilit_ve_hirsizlik_sahte_kimlik_cuzdani', count: 1),
      ],
      cashCost: 90,
      rewardXp: 95,
    ),

    // =========================================================================
    // 4. MUTFAK, GASTRONOMİ & ANTİKA RESTORASYONU (6 REÇETE)
    // =========================================================================
    CraftingRecipeModel(
      id: 'craft_gourmet_chef_kitchen',
      titleTr: 'Restoran Sınıfı Gourmet Mutfak Takımı',
      titleEn: 'Craft Gourmet Restaurant Cookware Set',
      descriptionTr: 'Döküm tava, bakır tencere, semaver ve şef bıçağını cilalayıp lüks otellere satılacak sete dönüştürün.',
      descriptionEn: 'Polish and assemble iron skillet, copper pot, tea samovar and chef knife into a luxury culinary kit.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_dokum_demir_tava', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_bakir_tencere', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_sef_bicagi', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_bakir_semaver', count: 1),
      ],
      cashCost: 150,
      rewardXp: 140,
    ),

    CraftingRecipeModel(
      id: 'craft_historic_tea_parlor',
      titleTr: 'Tarihi Çay Ocağı & Semaver Düzeneği',
      titleEn: 'Traditional Brass Tea Samovar Station',
      descriptionTr: 'Antika bakır semaveri porselen tabak seti ve el kahve değirmeni ile bir araya getirin.',
      descriptionEn: 'Pair antique brass samovar with gold-rimmed porcelain saucers and hand coffee mill.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_bakir_semaver', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_porselen_tabak_seti', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_el_kahve_degirmeni', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'sanat_antikalar_porselen_vazo', count: 1),
      ],
      cashCost: 140,
      rewardXp: 135,
    ),

    CraftingRecipeModel(
      id: 'craft_hand_forged_butcher_cleaver',
      titleTr: 'Dövme Karbon Çelik Kasap Satırı Isıl İşlemi',
      titleEn: 'Heat-Treat Hand Forged Meat Cleaver',
      descriptionTr: 'Kasap satırını zımparalayıp masif havan ve şef bıçağıyla profesyonel bileme işleminden geçirin.',
      descriptionEn: 'Hone, sharpen and temper heavy meat cleaver paired with white marble pestle.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_et_satiri', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_mermer_havan', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_biber_ogutucu', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_dokum_demir_tava', count: 1),
      ],
      cashCost: 110,
      rewardXp: 115,
    ),

    CraftingRecipeModel(
      id: 'craft_antique_phonograph_restoration',
      titleTr: 'Viktorya Gramofon & Ses Borusu Restorasyonu',
      titleEn: 'Restore Victorian Phonograph & Brass Horn',
      descriptionTr: 'Antika gramofonu yağlayıp pirinç şamdan ve porselen vazo ile lüks koleksiyonere hazırlayın.',
      descriptionEn: 'Clean, lubricate and polish gramophone acoustic horn with antique candelabra.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'sanat_antikalar_gramofon', count: 1),
        RecipeItemRequirement(itemCode: 'sanat_antikalar_samdan', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'sanat_antikalar_somine_saati', count: 1),
      ],
      cashCost: 175,
      rewardXp: 165,
    ),

    CraftingRecipeModel(
      id: 'craft_carved_oak_dining_suite',
      titleTr: 'Masif Meşe Oymalı Yemek Takımı Yenileme',
      titleEn: 'Refurbish Carved Oak Dining Furniture',
      descriptionTr: 'Ağır meşe yemek masası ve oyma sandalyeyi ahşap oklava talaşı ve gürgen vernikle parlatın.',
      descriptionEn: 'Sand and apply hand-rubbed wax finish onto heavy oak dining table and chairs.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 2,
      inputs: [
        RecipeItemRequirement(itemCode: 'ahsap_mobilya_yemek_masasi', count: 1),
        RecipeItemRequirement(itemCode: 'ahsap_mobilya_sandalye', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_ahsap_oklava', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'ahsap_mobilya_gardirob', count: 1),
      ],
      cashCost: 130,
      rewardXp: 125,
    ),

    CraftingRecipeModel(
      id: 'craft_mantel_clock_precision_rebuild',
      titleTr: 'Mekanik Şömine Saati Çark Revizyonu',
      titleEn: 'Precision Overhaul of Bronze Mantel Clock',
      descriptionTr: 'Pirinç şömine saatinin iç zembereğini kumpas ve tornavida ile hassas ayarlayın.',
      descriptionEn: 'Disassemble gear train and escapement wheel on bronze mantel clock to calibrate timing.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'sanat_antikalar_somine_saati', count: 1),
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_mikrometre_kumpas', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'sanat_antikalar_roma_bustu', count: 1),
      ],
      cashCost: 160,
      rewardXp: 155,
    ),

    // =========================================================================
    // 5. TIP, SİMYA & MELEZ ARCANE-TECH (7 REÇETE)
    // =========================================================================
    CraftingRecipeModel(
      id: 'craft_advanced_trauma_unit',
      titleTr: 'Askeri Sahra Acil Travma & Kurtarma Ünitesi',
      titleEn: 'Military Field Trauma & Resuscitation Suite',
      descriptionTr: 'Defibrilatör, metal cerrahi sandık, titanyum neşter ve turnikeyi steril acil müdahale ünitesinde toplayın.',
      descriptionEn: 'Combine portable AED defibrillator, surgical metal chest, scalpel kit and combat tourniquet.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'tip_ve_saglik_tasinabilir_defibrilator', count: 1),
        RecipeItemRequirement(itemCode: 'tip_ve_saglik_metal_ilk_yardim_cantasi', count: 1),
        RecipeItemRequirement(itemCode: 'tip_ve_saglik_cerrahi_nester_seti', count: 1),
        RecipeItemRequirement(itemCode: 'tip_ve_saglik_turnike', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'tip_ve_saglik_tibbi_stetoskop', count: 1),
      ],
      cashCost: 280,
      rewardXp: 260,
    ),

    CraftingRecipeModel(
      id: 'craft_alchemical_transmutation_distiller',
      titleTr: 'Kadim Hermetik Simya İmbiği & Cevher Arıtımı',
      titleEn: 'Grand Hermetic Alembic & Mineral Refinery',
      descriptionTr: 'Damıtma imbiği, mikroskop ve erlenmayer ile ametist cevherini damıtıp saf külçe altına dönüştürün.',
      descriptionEn: 'Refine raw amethyst geode clusters through glass distillation apparatus into purified bullion.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 4,
      inputs: [
        RecipeItemRequirement(itemCode: 'laboratuvar_simya_damitma_imbigi', count: 1),
        RecipeItemRequirement(itemCode: 'laboratuvar_simya_mikroskop', count: 1),
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_ametist_geodu', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_kulce_altin', count: 1),
      ],
      cashCost: 400,
      rewardXp: 350,
    ),

    CraftingRecipeModel(
      id: 'craft_arcane_plasma_rifle',
      titleTr: 'Rünik Plazma Tüfeği & Çekirdek Sentezi',
      titleEn: 'Synthesize Arcane Plasma Energy Rifle',
      descriptionTr: 'Uranyum çubuğunu plazma bileklik ve reaktör çekirdeği ile kaynaştırarak rünik plazma tüfeği üretin.',
      descriptionEn: 'Fuse radioactive uranium cell with arcane reactor core and runic board into an energy rifle.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 5,
      inputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_uranyum_cubugu', count: 1),
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_reaktor_cekirdegi', count: 1),
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_devre_karti', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_plazma_tufek', count: 1),
      ],
      cashCost: 550,
      rewardXp: 450,
    ),

    CraftingRecipeModel(
      id: 'craft_cybernetic_beam_katana',
      titleTr: 'Siberpunk Işın Katanası & Biyonik El Entegrasyonu',
      titleEn: 'Forge Cybernetic Neon Beam Katana',
      descriptionTr: 'Şövalye kılıcını reaktör çekirdeği ve sibernetik el ile birleştirerek yüksek voltajlı ışın katanası dövün.',
      descriptionEn: 'Imbue forged knight sword with cybernetic servo hand and crystal energy cell.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 4,
      inputs: [
        RecipeItemRequirement(itemCode: 'gercekci_silahlar_sovalye_kilici', count: 1),
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_sibernetik_el', count: 1),
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_reaktor_cekirdegi', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_isin_katanasi', count: 1),
      ],
      cashCost: 480,
      rewardXp: 400,
    ),

    CraftingRecipeModel(
      id: 'craft_nuclear_fuel_stabilization',
      titleTr: 'Radyoaktif Uranyum Çubuğu Stabilizasyonu',
      titleEn: 'Nuclear Fuel Rod Stabilization Process',
      descriptionTr: 'Ham uranyum yakıt çubuğunu titanyum blok ve asit erlenmayeri içinde nötralize ederek zırhlı enerji hücresine dönüştürün.',
      descriptionEn: 'Encapsulate radioactive uranium inside titanium casing to create stable power cells.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 4,
      inputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_uranyum_cubugu', count: 1),
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_titanyum_blok', count: 1),
        RecipeItemRequirement(itemCode: 'laboratuvar_simya_erlenmayer', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'melez_arcane_tech_reaktor_cekirdegi', count: 1),
      ],
      cashCost: 420,
      rewardXp: 380,
    ),

    CraftingRecipeModel(
      id: 'craft_crystallized_energy_scepter',
      titleTr: 'Ametist Kristal Küreli Büyücü Asası',
      titleEn: 'Crystal Orb Mystic Wizard Staff',
      descriptionTr: 'Antika ahşap oklava gövdesine ametist geodu ve altın külçe mühürleyerek kristal büyü asası yapın.',
      descriptionEn: 'Mount natural amethyst geode cluster atop polished wood shaft bound with gold wire.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_ametist_geodu', count: 1),
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_kulce_altin', count: 1),
        RecipeItemRequirement(itemCode: 'mutfak_gastronomi_ahsap_oklava', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'buyulu_silahlar_buyu_asasi', count: 1),
      ],
      cashCost: 320,
      rewardXp: 300,
    ),

    CraftingRecipeModel(
      id: 'craft_diamond_signet_heirloom',
      titleTr: 'Pırlanta Taşlı Kraliyet Mühür Yüzüğü Dövme',
      titleEn: 'Forge Diamond Royal Signet Ring Heirloom',
      descriptionTr: 'Parlak elmas ve gümüş külçeyi lehim istasyonunda mikron hassasiyetle işleyerek mühür yüzüğü üretin.',
      descriptionEn: 'Set brilliant-cut diamond into hand-carved silver bullion ring at the micro soldering bench.',
      type: RecipeType.assembly,
      requiredMasteryLevel: 3,
      inputs: [
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_parlak_elmas', count: 1),
        RecipeItemRequirement(itemCode: 'maden_ve_taslar_gumus_kulce', count: 1),
        RecipeItemRequirement(itemCode: 'tezgah_donanimlari_lehim_istasyonu', count: 1),
      ],
      outputs: [
        RecipeItemRequirement(itemCode: 'buyulu_takilar_yakut_yuzuk', count: 1),
      ],
      cashCost: 360,
      rewardXp: 320,
    ),
  ];

  /// Kategori veya türe göre filtreleme
  static List<CraftingRecipeModel> getByType(RecipeType type) {
    return all.where((r) => r.type == type).toList();
  }

  /// ID'ye göre reçete bulma
  static CraftingRecipeModel? getById(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }
}

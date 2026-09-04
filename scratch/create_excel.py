import os
import zipfile
import xml.etree.ElementTree as ET

def create_styled_xlsx(filename, sheet_name, headers, rows, col_widths=None):
    """
    Creates a professionally styled .xlsx file using standard Python library (zipfile + OpenXML).
    Zero external dependencies needed.
    """
    
    # 1. [Content_Types].xml
    content_types = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
    <Default Extension="xml" ContentType="application/xml"/>
    <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
    <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
    <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>"""

    # 2. _rels/.rels
    root_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>"""

    # 3. xl/_rels/workbook.xml.rels
    wb_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
    <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>"""

    # 4. xl/workbook.xml
    workbook_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
    <sheets>
        <sheet name="{escape_xml(sheet_name)}" sheetId="1" r:id="rId1"/>
    </sheets>
</workbook>"""

    # 5. xl/styles.xml
    # Style 0: Normal
    # Style 1: Header (Navy blue fill, Bold white text, centered)
    # Style 2: Data Odd row (light blue tint, border)
    # Style 3: Data Even row (white, border)
    styles_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
    <fonts count="3">
        <font><sz val="11"/><name val="Calibri"/><color rgb="FF222222"/></font>
        <font><b/><sz val="11"/><name val="Calibri"/><color rgb="FFFFFFFF"/></font>
        <font><b/><sz val="11"/><name val="Calibri"/><color rgb="FF1F497D"/></font>
    </fonts>
    <fills count="4">
        <fill><patternFill patternType="none"/></fill>
        <fill><patternFill patternType="gray125"/></fill>
        <fill><patternFill patternType="solid"><fgColor rgb="FF1F497D"/></patternFill></fill>
        <fill><patternFill patternType="solid"><fgColor rgb="FFF2F6FA"/></patternFill></fill>
    </fills>
    <borders count="2">
        <border><left/><right/><top/><bottom/><diagonal/></border>
        <border>
            <left style="thin"><color rgb="FFD9D9D9"/></left>
            <right style="thin"><color rgb="FFD9D9D9"/></right>
            <top style="thin"><color rgb="FFD9D9D9"/></top>
            <bottom style="thin"><color rgb="FFD9D9D9"/></bottom>
        </border>
    </borders>
    <cellXfs count="4">
        <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
        <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1">
            <alignment horizontal="center" vertical="center" wrapText="1"/>
        </xf>
        <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1">
            <alignment vertical="top" wrapText="1"/>
        </xf>
        <xf numFmtId="0" fontId="0" fillId="3" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1">
            <alignment vertical="top" wrapText="1"/>
        </xf>
    </cellXfs>
</styleSheet>"""

    # 6. xl/worksheets/sheet1.xml
    sheet_rows_xml = []
    
    # Column definitions (widths)
    cols_xml = []
    if col_widths:
        cols_xml.append('<cols>')
        for idx, width in enumerate(col_widths, start=1):
            cols_xml.append(f'<col min="{idx}" max="{idx}" width="{width}" customWidth="1"/>')
        cols_xml.append('</cols>')

    # Row 1: Headers
    header_cells = []
    for col_idx, h in enumerate(headers, start=1):
        col_letter = get_col_letter(col_idx)
        header_cells.append(f'<c r="{col_letter}1" s="1" t="inlineStr"><is><t>{escape_xml(h)}</t></is></c>')
    sheet_rows_xml.append(f'<row r="1" ht="28" customHeight="1">{"".join(header_cells)}</row>')

    # Data Rows
    for row_idx, row in enumerate(rows, start=2):
        row_cells = []
        style_id = 3 if row_idx % 2 == 1 else 2
        for col_idx, val in enumerate(row, start=1):
            col_letter = get_col_letter(col_idx)
            val_str = str(val) if val is not None else ""
            row_cells.append(f'<c r="{col_letter}{row_idx}" s="{style_id}" t="inlineStr"><is><t>{escape_xml(val_str)}</t></is></c>')
        sheet_rows_xml.append(f'<row r="{row_idx}">{"".join(row_cells)}</row>')

    sheet1_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
    {"".join(cols_xml)}
    <sheetData>
        {"".join(sheet_rows_xml)}
    </sheetData>
</worksheet>"""

    os.makedirs(os.path.dirname(os.path.abspath(filename)), exist_ok=True)
    with zipfile.ZipFile(filename, 'w', zipfile.ZIP_DEFLATED) as xlsx:
        xlsx.writestr('[Content_Types].xml', content_types)
        xlsx.writestr('_rels/.rels', root_rels)
        xlsx.writestr('xl/_rels/workbook.xml.rels', wb_rels)
        xlsx.writestr('xl/workbook.xml', workbook_xml)
        xlsx.writestr('xl/styles.xml', styles_xml)
        xlsx.writestr('xl/worksheets/sheet1.xml', sheet1_xml)

def escape_xml(text):
    if not isinstance(text, str):
        text = str(text)
    return text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;').replace("'", '&apos;')

def get_col_letter(col_idx):
    result = ""
    while col_idx > 0:
        col_idx, remainder = divmod(col_idx - 1, 26)
        result = chr(65 + remainder) + result
    return result

data = [
    [1, "Ev Ahşap Mobilyaları", "Masif ahşap yemek masası, oymalı sandalye, kitaplık rafı, rustik ahşap kapı, komodin", "knolling grid collection of rustic wooden home furniture, heavy oak dining table, carved wooden chair, bookshelf, vintage interior door, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [2, "Elektronik El Aletleri", "Akülü darbeli matkap, sıcak hava tabancası, dijital havya lehim istasyonu, multimetre, taşlama makinesi", "knolling grid collection of heavy duty electronic power tools, cordless impact drill, digital soldering station, heat gun, multimeter, angle grinder, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [3, "Ev Elektroniği (Beyaz Eşya)", "Paslanmaz çelik buzdolabı, retro çamaşır makinesi, kurutma makinesi, CRT tüplü TV, mikrodalga fırın", "knolling grid collection of vintage and modern home appliances, stainless steel refrigerator, front-load washing machine, retro CRT television, microwave, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [4, "Büyülü Silahlar (Arcane)", "Rünlü parlayan çift elli kılıç, kadim meşe büyü asası, alevli hançer, buz kristalleriyle kaplı yay, rünik tırpan", "knolling grid collection of enchanted fantasy weapons, glowing engraved runic greatsword, ancient oak wizard staff with floating crystal, flaming dagger, frosted ice bow, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [5, "Büyülü Zırhlar", "Ametist işlemeli göğüslük, rünik plakalı pantolon, ejderha pullu kask, ışıltılı deri eldivenler, hız botları", "knolling grid collection of enchanted mystical armor pieces, amethyst engraved breastplate, runic greaves, dragon scale full helmet, glowing arcane gauntlets, armored boots, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [6, "Büyülü Takılar & Tılsımlar", "Zümrüt taşlı altın muska kolye, safir damla küpeler, rünik manşet bileklik, gümüş halhal, yakut yüzük", "knolling grid collection of magical jewelry and talismans, emerald gold amulet necklace, sapphire gemstone earrings, runic silver cuff bracelet, ruby ring, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [7, "Gerçekçi Silahlar", "Taktik sürgülü tüfek, yarı otomatik 9mm tabanca, av bıçağı, çelik dövme kılıç, modern arbalet (tatar yayı)", "knolling grid collection of authentic realistic weapons, tactical bolt-action rifle, matte black 9mm pistol, steel hunting knife, forged arming sword, modern crossbow, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [8, "Kademeli Zırhlar (Tier 1: Bakır / Bronz)", "Dövme bakır göğüslük, bronz miğfer, bakır dizlikler, perçinli deri-bakır eldivenler, bronz kalkan", "knolling grid collection of tier 1 hammered copper and bronze armor pieces, copper cuirass, bronze spartan helmet, greaves, riveted copper gauntlets, round shield, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [9, "Kademeli Zırhlar (Tier 2: Çelik / Karbon)", "Cilalı sertleştirilmiş çelik göğüslük, çelik vizörlü kask, çelik eldivenler, mafsallı bacak zırhı", "knolling grid collection of tier 2 polished hardened steel knight armor, heavy steel breastplate, bascinet visor helmet, articulated gauntlets, plate sabatons, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [10, "Kademeli Zırhlar (Tier 3: Platinyum / Titanyum)", "Fütüristik platinyum-titanyum alaşımlı zırh, karbon takviyeli kompozit kask, şok emici taktik botlar", "knolling grid collection of tier 3 ultra modern titanium and platinum composite armor pieces, high-tech tactical ballistic vest, carbon fiber tactical helmet, reinforced exoskeleton boots, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [11, "Manuel El Aletleri & Çanta", "Paslı ağır çekiç, boru anahtarı, kombine pense, lokma takımı, metal alet çantası, tornavida seti", "knolling grid collection of classic mechanic hand tools, heavy steel hammer, pipe wrench, combination pliers, socket set, rugged red metal toolbox, screwdrivers, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [12, "Çeşitli Mobilyalar & Ev", "Kadife kanepe, yaylı deri yatak, pirinç abajur, antika el dokuması halı, ceviz gardırop, berjer", "knolling grid collection of domestic comfort furniture, tufted leather sofa, mattress, brass vintage floor lamp, rolled Persian carpet, walnut wardrobe, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [13, "Araba & Mekanik Parçaları", "Paslı V8 motor bloğu, krom egzoz manifoldu, deri yarış koltuğu, ahşap direksiyon, araba aküsü, turboşarj", "knolling grid collection of automotive scrap and performance car parts, V8 engine block, chrome exhaust manifold, leather bucket seat, wooden steering wheel, car battery, turbocharger, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [14, "Ofis Ekipmanları & Büro", "Lazer yazıcı, çift fanlı bilgisayar kasası, ergonomik ofis koltuğu, kahve makinesi, evrak imha makinesi", "knolling grid collection of modern office and tech equipment, laser multifunction printer, PC desktop tower, mesh ergonomic office chair, espresso coffee maker, paper shredder, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [15, "Sanat Eserleri & Antikalar", "Yağlı boya altın çerçeveli tablo, mermer büst heykeli, bronz şömine saati, porselen biblo vazosu", "knolling grid collection of high-value fine art and antique decor, classical oil painting with ornate gold frame, marble Roman bust statue, antique bronze mantel clock, porcelain vase, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [16, "Müzik Aletleri", "Vintage elektro gitar, pirinç trompet, gümüş flüt, keman ve yayı, trampet davul, akordeon", "knolling grid collection of vintage musical instruments, sunburst electric guitar, brass trumpet, polished silver flute, wooden violin with bow, snare drum, accordion, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [17, "Zanaat Tezgahı Çekirdek Donanımları", "Ultrasonik temizleme havuzu, hassas lehim istasyonu, mikrometre kumpas, döküm mengene, optik büyüteç", "knolling grid collection of precision workshop crafting bench equipment, ultrasonic cleaning bath chamber, precision SMD soldering station, digital micrometer caliper, cast iron bench vise, articulated magnifying lamp, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [18, "Laboratuvar, Kimya & Simya", "Cam damıtma imbiği, Bunsen ocağı, asit dolu damlalıklı şişeler, mikroskop, santrifüj tüpleri", "knolling grid collection of chemical distillation and alchemy laboratory glass apparatus, glass condenser coil flask, bunsen burner, amber acid reagent bottles, brass vintage microscope, test tubes rack, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [19, "Ağır Sanayi & Fabrika Parçaları", "Ağır buhar vanası, endüstriyel basınç göstergesi, dev döküm çark dişlisi, hidrolik silindir pistonu", "knolling grid collection of heavy industrial plumbing and factory machinery components, heavy brass steam valve, industrial pressure gauge manometer, cast iron gear cogwheels, hydraulic piston cylinder, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [20, "Taktik & Hayatta Kalma Donanımları", "Askeri su geçirmez sırt çantası, taktik gaz maskesi, çelik ordu matarası, dürbün, acil durum telsizi", "knolling grid collection of military survivalist and tactical field gear, coyote tactical backpack, military gas mask, steel canteen flask, rugged binoculars, military handheld radio transceiver, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"],
    [21, "Melez Eşyalar (Arcane-Tech)", "Neon plazma akülü büyü tüfeği, holografik kadim parşömen, siber-rünik katana, enerji kristali güç çekirdeği", "knolling grid collection of hybrid cyber-magic arcane technology equipment, plasma-infused runic rifle, glowing holographic ancient scroll device, cybernetic engraved neon katana, arcane energy crystal reactor core, studio product photography, clean isolated pure white background, frontal isometric angle, cinematic soft rim lighting, ultra sharp details, photorealistic AAA game asset, 8k resolution --v 6.0"]
]

headers = ["No", "Kategori", "İçereceği Eşyalar (Craft & Oyun İhtiyacı)", "Kopyalanabilir Yapay Zeka Promptu (Midjourney / Flux)"]
col_widths = [6, 28, 45, 85]
output_file = r"d:\github\depo\docs\Gorsel_Uretim_Prompt_Rehberi.xlsx"

create_styled_xlsx(output_file, "Eşya Prompt Rehberi", headers, data, col_widths)
print(f"EXCEL DOSYASI BAŞARIYLA OLUŞTURULDU: {output_file}")

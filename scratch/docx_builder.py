import os
import zipfile
import xml.etree.ElementTree as ET

def create_docx(filename, title, sections):
    """
    Creates a valid Microsoft Word (.docx) file using standard Python library (zipfile + XML).
    sections is a list of tuples: (heading_level, text) or ('table', headers, rows) or ('p', text)
    """
    
    # 1. [Content_Types].xml
    content_types = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
    <Default Extension="xml" ContentType="application/xml"/>
    <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
    <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>"""

    # 2. _rels/.rels
    rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>"""

    # 3. word/styles.xml
    styles = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:docDefaults>
        <w:rPrDefault>
            <w:rPr>
                <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
                <w:sz w:val="22"/>
                <w:color w:val="222222"/>
            </w:rPr>
        </w:rPrDefault>
    </w:docDefaults>
    <w:style w:type="paragraph" w:styleId="Title">
        <w:name w:val="Title"/>
        <w:rPr>
            <w:rFonts w:ascii="Calibri Light" w:hAnsi="Calibri Light"/>
            <w:b/>
            <w:sz w:val="52"/>
            <w:color w:val="1F497D"/>
        </w:rPr>
    </w:style>
    <w:style w:type="paragraph" w:styleId="Heading1">
        <w:name w:val="heading 1"/>
        <w:pPr>
            <w:spacing w:before="360" w:after="120"/>
        </w:pPr>
        <w:rPr>
            <w:rFonts w:ascii="Calibri Light" w:hAnsi="Calibri Light"/>
            <w:b/>
            <w:sz w:val="34"/>
            <w:color w:val="1F497D"/>
        </w:rPr>
    </w:style>
    <w:style w:type="paragraph" w:styleId="Heading2">
        <w:name w:val="heading 2"/>
        <w:pPr>
            <w:spacing w:before="240" w:after="80"/>
        </w:pPr>
        <w:rPr>
            <w:rFonts w:ascii="Calibri Light" w:hAnsi="Calibri Light"/>
            <w:b/>
            <w:sz w:val="28"/>
            <w:color w:val="2E74B5"/>
        </w:rPr>
    </w:style>
    <w:style w:type="paragraph" w:styleId="Heading3">
        <w:name w:val="heading 3"/>
        <w:pPr>
            <w:spacing w:before="180" w:after="60"/>
        </w:pPr>
        <w:rPr>
            <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
            <w:b/>
            <w:sz w:val="24"/>
            <w:color w:val="1F497D"/>
        </w:rPr>
    </w:style>
</w:styles>"""

    # 4. word/_rels/document.xml.rels
    doc_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>"""

    # 5. Build word/document.xml
    body_parts = []
    
    # Title
    body_parts.append(f"""
    <w:p>
        <w:pPr><w:pStyle w:val="Title"/><w:jc w:val="center"/></w:pPr>
        <w:r><w:t>{escape_xml(title)}</w:t></w:r>
    </w:p>
    <w:p>
        <w:pPr><w:jc w:val="center"/><w:spacing w:after="400"/></w:pPr>
        <w:r><w:rPr><w:i/><w:color w:val="555555"/></w:rPr><w:t>Flutter &amp; Flame Hibrit Mimarisi - Kapsamlı Üretim ve Sistem Tasarım Dokümanı</w:t></w:r>
    </w:p>
    """)

    for item in sections:
        type_ = item[0]
        if type_ == 'h1':
            body_parts.append(f"""
            <w:p>
                <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
                <w:r><w:t>{escape_xml(item[1])}</w:t></w:r>
            </w:p>""")
        elif type_ == 'h2':
            body_parts.append(f"""
            <w:p>
                <w:pPr><w:pStyle w:val="Heading2"/></w:pPr>
                <w:r><w:t>{escape_xml(item[1])}</w:t></w:r>
            </w:p>""")
        elif type_ == 'h3':
            body_parts.append(f"""
            <w:p>
                <w:pPr><w:pStyle w:val="Heading3"/></w:pPr>
                <w:r><w:t>{escape_xml(item[1])}</w:t></w:r>
            </w:p>""")
        elif type_ == 'p':
            body_parts.append(f"""
            <w:p>
                <w:pPr><w:spacing w:after="120"/></w:pPr>
                <w:r><w:t xml:space="preserve">{escape_xml(item[1])}</w:t></w:r>
            </w:p>""")
        elif type_ == 'bullet':
            body_parts.append(f"""
            <w:p>
                <w:pPr>
                    <w:ind w:left="360"/>
                    <w:spacing w:after="80"/>
                </w:pPr>
                <w:r><w:t>•  </w:t></w:r>
                <w:r><w:t xml:space="preserve">{escape_xml(item[1])}</w:t></w:r>
            </w:p>""")
        elif type_ == 'callout':
            body_parts.append(f"""
            <w:p>
                <w:pPr>
                    <w:pBdr>
                        <w:left w:val="single" w:sz="24" w:space="12" w:color="1F497D"/>
                    </w:pBdr>
                    <w:shd w:val="clear" w:color="auto" w:fill="F2F4F7"/>
                    <w:ind w:left="240" w:right="240"/>
                    <w:spacing w:before="120" w:after="120"/>
                </w:pPr>
                <w:r><w:rPr><w:b/><w:color w:val="1F497D"/></w:rPr><w:t>{escape_xml(item[1])}: </w:t></w:r>
                <w:r><w:t xml:space="preserve">{escape_xml(item[2])}</w:t></w:r>
            </w:p>""")
        elif type_ == 'code':
            lines = item[1].split('\n')
            code_runs = []
            for line in lines:
                code_runs.append(f'<w:p><w:pPr><w:shd w:val="clear" w:color="auto" w:fill="EFEFEF"/><w:spacing w:after="40"/><w:ind w:left="240"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="18"/><w:color w:val="333333"/></w:rPr><w:t xml:space="preserve">{escape_xml(line)}</w:t></w:r></w:p>')
            body_parts.append('\n'.join(code_runs))
        elif type_ == 'table':
            headers = item[1]
            rows = item[2]
            table_xml = ['<w:tbl><w:tblPr><w:tblBorders><w:top w:val="single" w:sz="8" w:space="0" w:color="CCCCCC"/><w:left w:val="none"/><w:bottom w:val="single" w:sz="8" w:space="0" w:color="CCCCCC"/><w:right w:val="none"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="E0E0E0"/><w:insideV w:val="none"/></w:tblBorders><w:tblCellMar><w:top w:w="120"/><w:left w:w="160"/><w:bottom w:w="120"/><w:right w:w="160"/></w:tblCellMar></w:tblPr>']
            
            # Header Row
            table_xml.append('<w:tr><w:trPr><w:tblHeader/></w:trPr>')
            for h in headers:
                table_xml.append(f'<w:tc><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="1F497D"/></w:tcPr><w:p><w:r><w:rPr><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="20"/></w:rPr><w:t>{escape_xml(h)}</w:t></w:r></w:p></w:tc>')
            table_xml.append('</w:tr>')
            
            # Data Rows
            for r_idx, row in enumerate(rows):
                fill = "F9FBFD" if r_idx % 2 == 1 else "FFFFFF"
                table_xml.append('<w:tr>')
                for cell in row:
                    table_xml.append(f'<w:tc><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="{fill}"/></w:tcPr><w:p><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{escape_xml(cell)}</w:t></w:r></w:p></w:tc>')
                table_xml.append('</w:tr>')
            table_xml.append('</w:tbl><w:p><w:pPr><w:spacing w:after="160"/></w:pPr></w:p>')
            body_parts.append('\n'.join(table_xml))

    doc_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:body>
        {''.join(body_parts)}
        <w:sectPr>
            <w:pgSz w:w="11906" w:h="16838"/>
            <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
        </w:sectPr>
    </w:body>
</w:document>"""

    os.makedirs(os.path.dirname(os.path.abspath(filename)), exist_ok=True)
    with zipfile.ZipFile(filename, 'w', zipfile.ZIP_DEFLATED) as docx:
        docx.writestr('[Content_Types].xml', content_types)
        docx.writestr('_rels/.rels', rels)
        docx.writestr('word/_rels/document.xml.rels', doc_rels)
        docx.writestr('word/styles.xml', styles)
        docx.writestr('word/document.xml', doc_xml)

def escape_xml(text):
    if not isinstance(text, str):
        text = str(text)
    return text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;').replace("'", '&apos;')

print("Script template ready")

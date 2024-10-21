import os
import sys
from xml.etree import ElementTree as ET
from pathlib import Path
from xml.dom import minidom
import pandas as pd

def add_pdf_to_sitemap(sitemap_file: str, site_url: str, extensions: str, subdirectory: str):
    root = ET.parse(sitemap_file).getroot()
    # Iterate through the URLs and check for PDF content
    for url_elem in root.findall("{http://www.sitemaps.org/schemas/sitemap/0.9}url"):
        loc = url_elem.find("{http://www.sitemaps.org/schemas/sitemap/0.9}loc").text
        lastmod = url_elem.find("{http://www.sitemaps.org/schemas/sitemap/0.9}lastmod").text
        yield { "loc": loc, "lastmod": lastmod }
        # Remove the site URL from the beginning of the path
        relative_path = loc.replace(site_url, "")
        subdirectory = subdirectory.strip("/")
        if relative_path.startswith(subdirectory) or relative_path.startswith(f'/{subdirectory}'):
            path = Path(relative_path)
            parent_path = str(path.parent).strip("/")
            file_name, _ = path.name.split(".", 1)
            for extension in extensions.split(','):
                extention_path = Path(os.path.join(
                    str(Path(sitemap_file).parent).strip("/"), 
                    parent_path, 
                    f"{file_name}.{extension}"))
                if extention_path.exists():
                    extention_url = os.path.join(
                        site_url,
                        parent_path, 
                        f"{file_name}.{extension}")
                    yield { "loc": extention_url, "lastmod": lastmod }

if __name__ == "__main__":
    sitemap_path = "_site/sitemap.xml"
    url_list = pd.DataFrame(
        add_pdf_to_sitemap(sitemap_path, "https://toknow.ai", sys.argv[1], "posts")
        ).drop_duplicates(keep='first').to_dict('records')
    # for loc_lastmod in urlset:
    urlset = ET.Element("urlset")
    urlset.set("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")
    # Add URL entries
    for loc_lastmod in url_list:
        url_tree: ET.Element = ET.SubElement(urlset, "url")
        url_loc_tree = ET.SubElement(url_tree, "loc")
        url_loc_tree.text = loc_lastmod["loc"]
        url_lastmod_tree = ET.SubElement(url_tree, "lastmod")
        url_lastmod_tree.text = loc_lastmod["lastmod"]
    xml_string = minidom.parseString(ET.tostring(urlset)).toprettyxml(indent="  ", encoding="UTF-8").decode("UTF-8")
    with open(sitemap_path, "w") as f:
        f.write(xml_string)
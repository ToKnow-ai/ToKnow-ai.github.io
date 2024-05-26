import sys
from nbformat import NotebookNode, v4, write as nb_write
import re
import yaml
import strip_markdown

def remove_lists(markdown_text):
    # Remove ordered lists
    markdown_text = re.sub(r'^\d+\.\s*', '', markdown_text, flags=re.MULTILINE)
    
    # Remove unordered lists
    markdown_text = re.sub(r'^\*\s*', '', markdown_text, flags=re.MULTILINE)
    markdown_text = re.sub(r'^\+\s*', '', markdown_text, flags=re.MULTILINE)
    markdown_text = re.sub(r'^-\s*', '', markdown_text, flags=re.MULTILINE)
    
    return markdown_text

def extract_quarto_metadata(cells: list[NotebookNode]) -> list[NotebookNode]:
    new_cells = []
    metadata = {}
    pattern = r"<!--\s*metadata:\s*(.*?)\s*-->\s*(.*?)\s*(?=<!-- metadata:|$)"

    for cell in cells:
        if cell and cell.cell_type == 'markdown':
            matches = re.findall(pattern, cell.source, re.DOTALL)
            skip_this_cell = False
            for (metadata_key, meatadata_value) in matches:
                meatadata_value = meatadata_value.strip()
                if len(metadata_key) > 0 and len(meatadata_value) > 0:
                    # html list in listings page spoils UI.
                    metadata[metadata_key] = remove_lists(strip_markdown.strip_markdown(meatadata_value.replace("\n\n", "\n")))
                    skip_this_cell = True
            if skip_this_cell:
                continue
        new_cells.append(cell)
    if any(metadata):
        source = yaml.dump(metadata)
        metadata_cell = v4.new_markdown_cell(source=f'---\n{source}\n---')
        new_cells.insert(0, metadata_cell)
    return new_cells

# read notebook from stdin
notebook = v4.reads(sys.stdin.read())

notebook.cells = extract_quarto_metadata(notebook.cells)

# write notebook to stdout 
nb_write(notebook, sys.stdout)
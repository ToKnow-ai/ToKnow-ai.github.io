import sys
from nbformat import NotebookNode, v4, write as nb_write
import re
import yaml

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
    pattern = r"<!--\s*metadata:\s*(.*?)\s*-->"

    for cell in cells:
        if cell and cell.cell_type == 'markdown':
            match = re.search(pattern, cell.source, re.IGNORECASE)
            if match:
                metadata_key = match.group(1)
                if metadata_key:
                    splits = re.split(pattern, cell.source, re.IGNORECASE)
                    if len(splits) > 2:
                        meatadata_value = splits[-1]
                        if len(meatadata_value) > 0 and len(meatadata_value.strip()) > 0:
                          # html list in listings page spoils UI.
                          metadata[metadata_key] = remove_lists(meatadata_value.strip().replace("\n\n", "\n"))
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
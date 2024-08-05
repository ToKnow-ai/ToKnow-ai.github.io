"""Quarto notebook filter"""

import random
import re
import string
import sys
from nbformat import NotebookNode, v4
from nbformat import write as nb_write

markdown_matadata_id = 'markdown-matadata-id'

def generate_unique_alphanumeric(length=20):
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(length))

def option_source(source: str) -> str:
    pattern = r'^\s*<!--\s*#\s*\|\s*(.*\s*:\s*.*)\s*-->\s*$'
    match = re.search(pattern, source)
    if match:
        return match.groups()[0]
    return None

def handle_options(cells: list[NotebookNode]) -> list[NotebookNode]:
    new_cells = []
    for cell in cells:
        if cell and cell.cell_type == 'markdown':
            metadata = cell.metadata or {}
            sources: list[str] = cell.source.split('\n')
            option_sources = [f'#|{option_source(i)}' for i in sources if option_source(i) is not None]
            non_option_sources = [i for i in sources if option_source(i) is None]
            if len(option_sources) > 0:
                metadata = {**metadata, markdown_matadata_id: generate_unique_alphanumeric()}
                option_sources.append('1+1')
                new_code_cell = v4.new_code_cell(source='\n'.join(option_sources), metadata=metadata)
                new_cells.append(new_code_cell)
            modified_markdown_cell = v4.new_markdown_cell(source='\n'.join(non_option_sources), metadata=metadata)
            new_cells.append(modified_markdown_cell)
        else:
            new_cells.append(cell)
    return new_cells

# read notebook from stdin
notebook = v4.reads(sys.stdin.read())

notebook.cells = handle_options(notebook.cells)

nb_write(notebook, open('howdy.ipynb', 'w'))

# write notebook to stdout
nb_write(notebook, sys.stdout)

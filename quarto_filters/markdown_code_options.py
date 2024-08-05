"""
This file contains functions for handling markdown code options in Jupyter notebooks.
"""

import re
import sys
from nbformat import NotebookNode, v4
from nbformat import write as nb_write

MARKDOWN_CODE_CELL = 'is-a-markdown-code-cell'

def option_source(source_line: str) -> str:
    """
    Extracts the option from a source line in the format: <!-- # | option_name : option_value -->
    
    Parameters:
        source_line (str): The source line to extract the option from.
    
    Returns:
        str: The extracted option value.
    """
    pattern = r'^\s*<!--\s*#\s*\|\s*(.*\s*:\s*.*)\s*-->\s*$'
    match = re.search(pattern, source_line)
    if match:
        return match.groups()[0]
    return None

def option_or_source_line(source_line: str) -> str:
    """
    Returns the option line if it exists, otherwise returns the source line.

    Parameters:
    source_line (str): The source line to check for an option line.

    Returns:
    str: The option line if it exists, otherwise the source line.
    """
    option_line = option_source(source_line)
    if option_line is not None:
        return f'#|{option_line}'
    return source_line

def handle_options(cells: list[NotebookNode]) -> list[NotebookNode]:
    """
    Transforms markdown cells in the given list of cells that contain CODE OPTIONS into code cells.
    Later, using `markdown_code_options.lua`, the code cells are parsed as markdown.

    Args:
        cells (list[NotebookNode]): A list of NotebookNode objects representing cells.

    Returns:
        list[NotebookNode]: A list of transformed NotebookNode objects.

    """
    new_cells = []
    for cell in cells:
        if cell and cell.cell_type == 'markdown':
            source_lines: list[str] = cell.source.split('\n')
            if any([option_source(i) is not None for i in source_lines]):
                source = '\n'.join([option_or_source_line(i) for i in source_lines])
                metadata = { **cell.metadata, MARKDOWN_CODE_CELL: True }
                cell = v4.new_code_cell(source=source, metadata=metadata)
        new_cells.append(cell)
    return new_cells

# read notebook from stdin
notebook = v4.reads(sys.stdin.read())

notebook.cells = handle_options(notebook.cells)

# write notebook to stdout
nb_write(notebook, sys.stdout)

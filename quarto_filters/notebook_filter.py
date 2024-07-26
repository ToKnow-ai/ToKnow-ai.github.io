"""Quarto notebook filter"""

import sys
import re
from typing import Literal
from nbformat import NotebookNode, v4, write as nb_write
import yaml
import mistune
from bs4 import BeautifulSoup

KeyType = Literal['strip_markdown', 'preserve_cell', 'is_array']
default_options: dict[KeyType, bool] = {
    'strip_markdown': True,
    'preserve_cell': False,
    'is_array': False,
}

def get_html(markdown: str) -> BeautifulSoup:
    """
    Converts markdown to HTML using the mistune library and returns a BeautifulSoup object.

    Args:
        markdown (str): The markdown string to be converted.

    Returns:
        BeautifulSoup: A BeautifulSoup object representing the converted HTML.
    """
    html = mistune.create_markdown()(markdown)
    return BeautifulSoup(html, features='html.parser')

def parse_metadata_key(key: str, value: str) -> tuple[str, str, dict[KeyType, bool]]:
    """
    Parses the metadata key and value and returns a tuple with the parsed key and value.

    Args:
        key (str): The metadata key.
        value (str): The metadata value.

    Returns:
        tuple: A tuple containing the parsed key and value.

    Raises:
        ValueError: If the key type is not 'date' or 'array'.
    """
    key = key.strip()
    value = value.strip()
    (key, *_options) = key.split(',', 1)
    key_dict_options: dict[KeyType, bool] = {
        **default_options,
        **{
            option_key: get_bool_option(option_value or False)
            for option_key, option_value
            in [
                i.strip().split('=')
                for i
                in (_options[0].split(',') if len(_options) > 0 else [])
            ]
            if len(str(option_key).strip()) > 0
        }
    }
    key = key.strip()
    if key_dict_options['strip_markdown']:
        new_value: str = get_html(value).get_text().replace("\n\n", "\n").strip()
        value = new_value
    if key_dict_options['is_array']:
        html = get_html(value)
        list_items = html.find_all('li')
        new_values = [item.get_text(strip=True) for item in list_items]
        value = new_values
    return (key, value, key_dict_options)

def get_bool_option(strip_markdown: str|None|bool):
    """
    Converts the given value to a boolean option.

    Args:
        strip_markdown (str|None|bool): The value to be converted.

    Returns:
        bool: The boolean representation of the value.
    """
    strip_markdown = str(strip_markdown).lower().strip()
    return strip_markdown in ('true', '1')

def remove_lists(markdown_text: str):
    """
    Removes ordered and unordered lists from the given markdown text.

    Args:
        markdown_text (str): The input markdown text.

    Returns:
        str: The markdown text with lists removed.
    """
    # Remove ordered lists
    markdown_text = re.sub(r'^\d+\.\s*', '', markdown_text, flags=re.MULTILINE)
    # Remove unordered lists
    markdown_text = re.sub(r'^\*\s*', '', markdown_text, flags=re.MULTILINE)
    markdown_text = re.sub(r'^\+\s*', '', markdown_text, flags=re.MULTILINE)
    markdown_text = re.sub(r'^-\s*', '', markdown_text, flags=re.MULTILINE)
    return markdown_text

def extract_quarto_metadata(cells: list[NotebookNode]) -> list[NotebookNode]:
    """
    Extracts Quarto metadata from markdown cells in a notebook.

    Args:
        cells (list[NotebookNode]): List of notebook cells.

    Returns:
        list[NotebookNode]: List of notebook cells with Quarto metadata extracted.
    """
    new_cells = []
    metadata = {}
    pattern = r"<!--\s*metadata:\s*(.*?)\s*-->\s*(.*?)\s*(?=<!-- metadata:|$)"

    for cell in cells:
        if cell and cell.cell_type == 'markdown':
            matches = re.findall(pattern, cell.source, re.DOTALL)
            preserve_cell_s: list[bool] = []
            for (metadata_key, metadata_value) in matches:
                if len(metadata_key.strip()) > 0 and len(metadata_value) > 0:
                    metadata_key, metadata_value, options = parse_metadata_key(metadata_key, metadata_value)
                    # html list in listings page spoils UI.
                    metadata[metadata_key] = \
                        metadata.get(metadata_key, []) + metadata_value \
                            if isinstance(metadata_value, list) \
                            else metadata_value
                    preserve_cell_s.append(options['preserve_cell'])
            if not any(preserve_cell_s):
                continue
        new_cells.append(cell)
    if any(metadata):
        source = yaml.dump(
            metadata,
            sort_keys=False,
            indent=4)
        metadata_cell = v4.new_markdown_cell(source=f'---\n{source}\n---')
        new_cells.insert(0, metadata_cell)
    return new_cells

# read notebook from stdin
notebook = v4.reads(sys.stdin.read())

notebook.cells = extract_quarto_metadata(notebook.cells)

# write notebook to stdout
nb_write(notebook, sys.stdout)

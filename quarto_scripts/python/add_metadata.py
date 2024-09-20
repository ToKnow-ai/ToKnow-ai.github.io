import sys
from nbformat import v4, write as nb_write
import yaml

def string_to_yaml(input_string: str) -> str:
    """
    Converts a dot-notated string into a nested YAML formatted string.
    Args:
        input_string (str): The input string containing key-value pairs separated by '='. 
                            Nested keys are separated by dots ('.'). Entries are separated 
                            by new lines ('\n') or semicolons (';').
    Returns:
        str: A YAML formatted string representing the nested dictionary structure.
    Example:
        input_string = "a.b.c=value1\nd.e=value2"
        yaml_string = string_to_yaml(input_string)
        # yaml_string will be:
        # a:
        #   b:
        #     c: value1
        # d:
        #   e: value2
    """
    def nested_dict(keys: list[str], value: str) -> dict[str, str] | dict[str, dict[str, str]]:
        if len(keys) == 1:
            return {keys[0]: value}
        return {keys[0]: nested_dict(keys[1:], value)}
    
    def update(
            merged_entries: dict[str, str] | dict[str, dict[str, str]], 
            single_entry: dict[str, str] | dict[str, dict[str, str]]):
        for key, value in single_entry.items():
            if isinstance(value, dict):
                merged_entries[key] = update(merged_entries.get(key, {}), value)
            else:
                merged_entries[key] = value
        return merged_entries

    merged_entry_objs = {}
    # the entries are split by new line (\n) or `;`
    entries = input_string.replace('\n', ';').split(';')
    for entry in entries:
        if '=' in entry:
            key_path, value = entry.split('=')
            keys: list[str] = key_path.strip().split('.')
            value: str = value.strip()
            
            entry_obj = nested_dict(keys, value)
            
            update(merged_entry_objs, entry_obj)

    return yaml.dump(merged_entry_objs, default_flow_style=False)

# read notebook from stdin
notebook = v4.reads(sys.stdin.read())

yaml_str = string_to_yaml(sys.argv[1])

# [`ipynb-output: all,none,best`](https://quarto.org/docs/reference/formats/ipynb.html) does not WORK
source = f"""---
{yaml_str}
---
"""
notebook.cells = [v4.new_markdown_cell(source=source)] + notebook.cells

# write notebook to stdout
nb_write(notebook, sys.stdout)

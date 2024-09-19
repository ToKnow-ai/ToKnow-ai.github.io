import sys
from nbformat import v4, write as nb_write
import yaml

def string_to_yaml(input_string):
  def nested_dict(keys, value):
      if len(keys) == 1:
          return {keys[0]: value}
      return {keys[0]: nested_dict(keys[1:], value)}

  result = {}
  for line in input_string.split('\n'):
      if '=' in line:
          key_path, value = line.split('=')
          keys = key_path.strip().split('.')
          value = value.strip()
          
          temp = nested_dict(keys, value)
          
          def update(d, u):
              for k, v in u.items():
                  if isinstance(v, dict):
                      d[k] = update(d.get(k, {}), v)
                  else:
                      d[k] = v
              return d
          
          update(result, temp)

  return yaml.dump(result, default_flow_style=False)

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

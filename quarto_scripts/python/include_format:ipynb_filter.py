import sys
from nbformat import v4, write as nb_write

# read notebook from stdin
notebook = v4.reads(sys.stdin.read())

# [`ipynb-output: all,none,best`](https://quarto.org/docs/reference/formats/ipynb.html) does not WORK
source = """---
format:
  ipynb
---
"""
notebook.cells = [v4.new_markdown_cell(source=source)] + notebook.cells

# write notebook to stdout
nb_write(notebook, sys.stdout)

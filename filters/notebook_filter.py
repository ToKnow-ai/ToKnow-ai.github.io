import sys
import nbformat
from nbformat import NotebookNode

# read notebook from stdin
nb: NotebookNode = nbformat.reads(sys.stdin.read(), as_version = 4) as NotebookNode

# prepend a comment to the source of each cell
for index, cell in enumerate(nb.cells):
  if cell.cell_type == 'code':
     cell.source = "# comment\n" + cell.source
  
# write notebook to stdout 
nbformat.write(nb, sys.stdout)
import os
import glob
import shutil
from pathlib import Path
import argparse

def copy_files(input_glob_pattern: str, output_path_template: str):
    # Get all files matching the source pattern
    input_files = glob.glob(input_glob_pattern, recursive=True)
    
    for input_file in input_files:
        # Create the target file path
        source_path = Path(input_file)

        if source_path.is_file():
            template_options = { 
                'name': source_path.stem,
                'ext': source_path.suffix[1:]
            }
            subpath = output_path_template.format(**template_options)
            relative_path = source_path.parent / subpath
            resolved_path = relative_path.resolve()
            # Create the directory if it doesn't exist
            os.makedirs(os.path.dirname(resolved_path), exist_ok=True)
            
            # Copy the file
            shutil.copy2(input_file, resolved_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Copy files based on glob patterns")
    parser.add_argument("input_glob_pattern", help="Input glob pattern, relative ro running directory (e.g., 'posts/**/*.ipynb')")
    parser.add_argument("output_glob_path", help="Output glob path, relative to input file (e.g., '*.render.ipynb')")
    
    args = parser.parse_args()
    
    copy_files(args.input_glob_pattern, args.output_glob_path)
    print("Copy operation completed.")
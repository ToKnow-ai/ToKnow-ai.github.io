import argparse
import glob
import os
import shutil
from datetime import datetime

TEMP_DIR_PREFIX = '.quarto-temp-dir_' # Added to ignored files (quarto and git)
TEMP_DIR_PREFIX_GLOB = f"{TEMP_DIR_PREFIX}*"

def clear_old_temp_dirs(base_dir):
    """Clear all temporary directories that start with .temp-"""
    temp_dir_pattern = os.path.join(base_dir, "**", TEMP_DIR_PREFIX_GLOB)
    temp_dirs = glob.glob(temp_dir_pattern, recursive=True)
    
    for dir_path in temp_dirs:
        if os.path.isdir(dir_path):
            shutil.rmtree(dir_path)
            print(f"Removed temporary directory: {dir_path}")

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Copy files to temp directories based on glob pattern.")
    parser.add_argument("glob_pattern", help="Glob pattern to fetch files")
    args = parser.parse_args()

    # Create a timestamp for the temp directory name
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    temp_dir_name = f"{TEMP_DIR_PREFIX}{timestamp}"

    # Fetch files based on the glob pattern
    # The glob.glob function in Python does not match files or directories
    # that start with a dot (.) by default because these are
    # considered hidden files in Unix-like systems.
    files = glob.glob(args.glob_pattern, recursive=True)

    for file_path in files:
        # Get the directory of the original file
        original_dir = os.path.dirname(file_path)
        
        # Create the new temp directory path
        temp_dir_path = os.path.join(original_dir, temp_dir_name)
        
        # Create the temp directory if it doesn't exist
        os.makedirs(temp_dir_path, exist_ok=True)
        
        # Get the filename
        filename = os.path.basename(file_path)
        
        # Create the new file path in the temp directory
        new_file_path = os.path.join(temp_dir_path, filename)
        
        # Copy the file to the new location
        shutil.copy2(file_path, new_file_path)
        
        print(f"Copied {file_path} to {new_file_path}")     

if __name__ == "__main__":
    # Clear old temporary directories
    clear_old_temp_dirs(".")
    
    main()
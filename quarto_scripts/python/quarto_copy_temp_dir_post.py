import os
import glob
import shutil
from quarto_copy_temp_dir_pre import clear_old_temp_dirs, TEMP_DIR_PREFIX_GLOB

def copy_back_and_clear(base_dir):
    """Copy files back from .temp-* directories and remove them"""
    temp_dir_pattern = os.path.join(base_dir, "**", TEMP_DIR_PREFIX_GLOB)
    temp_dirs = glob.glob(temp_dir_pattern, recursive=True)

    for temp_dir in temp_dirs:
        # Get all files in the temp directory
        temp_files = glob.glob(os.path.join(temp_dir, "*"))
        
        for temp_file in temp_files:
            # Construct the original file path
            original_dir = os.path.dirname(os.path.dirname(temp_file))
            original_file = os.path.join(original_dir, os.path.basename(temp_file))
            
            # Copy the file back, overwriting the original
            shutil.copy2(temp_file, original_file)
            print(f"Copied {temp_file} back to {original_file}")

        # Remove the temp directory after copying files back
        shutil.rmtree(temp_dir)
        print(f"Removed temporary directory: {temp_dir}")

def main():
    # Copy files back from .temp-* directories and remove them
    copy_back_and_clear(".")

    # Clear any remaining .temp-* directories
    clear_old_temp_dirs(".")

if __name__ == "__main__":
    main()
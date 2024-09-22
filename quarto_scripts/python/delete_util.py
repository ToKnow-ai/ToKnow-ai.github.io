import argparse
import os
import glob
import shutil

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete files based on glob patterns")
    parser.add_argument("delete_glob_pattern", help="Render files glob pattern, relative ro running directory (e.g., 'posts/**/*.render.ipynb')")
    args = parser.parse_args()
    files_or_dirs = glob.glob(args.delete_glob_pattern, recursive=True)
    for file_or_dir in files_or_dirs:
        if os.path.isfile(file_or_dir):
            os.remove(file_or_dir)  # Delete a file
        elif os.path.isdir(file_or_dir):
            shutil.rmtree(file_or_dir)  # Delete a directory and all its contents
            print(f"Deleted directory: {os.path.basename(file_or_dir)}")
        else:
            print(f"Path does not exist: {file_or_dir}")
    print(f"Delete operation completed -> {args.delete_glob_pattern}")
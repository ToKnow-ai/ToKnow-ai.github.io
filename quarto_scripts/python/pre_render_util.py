"""
This script does the following:

1. It takes two command-line arguments: a glob pattern and a Python script name.
2. It finds all files matching the glob pattern.
3. For each matching file, it:
    a. Reads the content of the file.
    b. Executes the specified Python script, passing the file content as stdin.
    c. Captures the output of the script.
    d. Writes the output back to the original file.
"""

import os
import sys
import glob
import subprocess

def main():
    if len(sys.argv) < 3:
        print("Usage: python script.py <glob_pattern> <python_script>", file=sys.stderr)
        sys.exit()

    glob_pattern = sys.argv[1]
    python_script = sys.argv[2]
    python_script_args = sys.argv[3:] or []

    # Get all files matching the glob pattern
    matching_filenames = glob.glob(glob_pattern, recursive=True)

    for matched_file in matching_filenames:
        try:
            with open(matched_file, 'r', encoding='utf-8') as f:
                content = f.read()

            # Run the provided Python script
            result = subprocess.run(
                [sys.executable, python_script] + python_script_args,
                input=content,
                capture_output=True,
                text=True,
                check=False)

            if result.returncode != 0:
                print(f"Error processing {matched_file}:", file=sys.stderr)
                print(result.stderr, file=sys.stderr)
                continue

            # Write the output back to the file
            with open(matched_file, 'w', encoding='utf-8') as f:
                f.write(result.stdout)
        except Exception as e:
            print(f"Error processing {matched_file}: {str(e)}", file=sys.stderr)
    print(f"Pre-render complated for {os.path.basename(python_script)}")

if __name__ == "__main__":
    main()
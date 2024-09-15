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

import sys
import glob
import subprocess

def main():
    if len(sys.argv) < 3:
        print("Usage: python script.py <glob_pattern> <python_script>", file=sys.stderr)
        sys.exit()

    glob_pattern = sys.argv[1]
    python_script = sys.argv[2]

    # Get all files matching the glob pattern
    matching_files = glob.glob(glob_pattern)

    for file in matching_files:
        try:
            with open(file, 'r', encoding='utf-8') as f:
                content = f.read()

            # Run the provided Python script
            result = subprocess.run(
                [sys.executable, python_script],
                input=content,
                capture_output=True,
                text=True,
                check=False)

            if result.returncode != 0:
                print(f"Error processing {file}:", file=sys.stderr)
                print(result.stderr, file=sys.stderr)
                continue

            # Write the output back to the file
            with open(file, 'w', encoding='utf-8') as f:
                f.write(result.stdout)

            print(f"Processed {file}", file=sys.stderr)
        except Exception as e:
            print(f"Error processing {file}: {str(e)}", file=sys.stderr)

if __name__ == "__main__":
    main()
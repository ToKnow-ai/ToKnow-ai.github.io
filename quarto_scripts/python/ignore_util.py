import glob
import sys
import yaml

def ignore_files(profile_path, files_glob_pattern):
    files = glob.glob(files_glob_pattern, recursive=True)
    with open(profile_path, 'w', encoding='utf-8') as yaml_file:
        development_profile = {
            "project": {
                "render": [f"!{file}" for file in files],
            },
        }
        yaml.dump(development_profile, yaml_file, default_flow_style=False, encoding='utf-8')

if __name__ == "__main__":
    profile_path = sys.argv[1]
    files_glob_pattern = sys.argv[2]
    ignore_files(profile_path, files_glob_pattern)
    print("Ignore operation completed.")
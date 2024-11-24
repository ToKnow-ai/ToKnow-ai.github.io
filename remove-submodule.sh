#!/bin/bash

# Check if a submodule path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <submodule_path>"
    echo "Example: $0 path/to/submodule"
    exit 1
fi

SUBMODULE_PATH=$1

# Deinitialize the submodule
git submodule deinit -f "$SUBMODULE_PATH"

# Remove the submodule from .git/modules
rm -rf ".git/modules/$SUBMODULE_PATH"

# Remove the submodule from the working directory
git rm -f "$SUBMODULE_PATH"

# Commit the changes
git commit -m "Remove submodule $SUBMODULE_PATH"

echo "Submodule $SUBMODULE_PATH has been successfully removed."
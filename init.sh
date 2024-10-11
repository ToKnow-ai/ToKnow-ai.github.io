#!/bin/bash

# Name of the virtual environment
VENV_NAME=".env"

# Check if the virtual environment already exists
if [ -d "$VENV_NAME" ]; then
    echo "Virtual environment $VENV_NAME already exists. Activating..."
    source "$VENV_NAME/bin/activate"
else
    echo "Creating new virtual environment $VENV_NAME..."
    python3 -m venv "$VENV_NAME"
    source "$VENV_NAME/bin/activate"
fi

# Check if the activation was successful
if [ $? -eq 0 ]; then
    echo "Virtual environment activated successfully."
else
    echo "Failed to activate virtual environment. Exiting."
    exit 1
fi

# Install or upgrade pip
pip install --upgrade pip

# Install packages from python.requirements.txt
if [ -f "python.requirements.txt" ]; then
    echo "Installing packages from python.requirements.txt..."
    pip install -r python.requirements.txt
else
    echo "python.requirements.txt not found. Skipping package installation."
fi

echo "Environment setup complete. You can now run your Python scripts."
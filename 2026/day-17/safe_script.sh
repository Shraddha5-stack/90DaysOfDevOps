#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Creating directory..."

mkdir /tmp/devops-test || echo "Directory already exists"

echo "Entering directory..."

cd /tmp/devops-test || {
    echo "Failed to enter directory"
    exit 1
}

echo "Creating file..."

touch demo.txt || {
    echo "Failed to create file"
    exit 1
}

echo "Script completed successfully."


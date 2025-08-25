#!/bin/bash

# Script to download uthash.h header-only library
# Part of TDD approach for usbX project

set -e

UTHASH_URL="https://raw.githubusercontent.com/troydhanson/uthash/master/include/uthash.h"
INCLUDE_DIR="include"
SRC_DIR="src"

echo "=== uthash Download Script ==="
echo

# Create directories if they don't exist
mkdir -p "$INCLUDE_DIR"
mkdir -p "$SRC_DIR"

# Function to download uthash
download_uthash() {
    local target_dir="$1"
    local target_file="$target_dir/uthash.h"
    
    echo "Downloading uthash.h to $target_file..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -s -L "$UTHASH_URL" -o "$target_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$UTHASH_URL" -O "$target_file"
    else
        echo "Error: Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    if [ -f "$target_file" ]; then
        echo "✓ Successfully downloaded uthash.h to $target_file"
        echo "  File size: $(wc -c < "$target_file") bytes"
    else
        echo "✗ Failed to download uthash.h"
        exit 1
    fi
}

# Check if uthash.h already exists in include/
if [ -f "$INCLUDE_DIR/uthash.h" ]; then
    echo "uthash.h already exists in $INCLUDE_DIR/"
    echo "Use --force to re-download"
    if [ "$1" != "--force" ]; then
        exit 0
    fi
fi

# Download to include/ directory (preferred location)
download_uthash "$INCLUDE_DIR"

# Also copy to src/ for backward compatibility if needed
if [ ! -f "$SRC_DIR/uthash.h" ] || [ "$1" = "--force" ]; then
    echo "Copying uthash.h to $SRC_DIR/ for compatibility..."
    cp "$INCLUDE_DIR/uthash.h" "$SRC_DIR/uthash.h"
    echo "✓ Copied to $SRC_DIR/uthash.h"
fi

echo
echo "=== Download Complete ==="
echo "uthash.h is now available in both include/ and src/ directories"
echo "You can now compile your project with uthash support!"
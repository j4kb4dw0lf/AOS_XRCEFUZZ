#!/bin/bash

# Cartelle di input/output
UNPATCHED_DIR="unpatched_files"
PATCHED_DIR="patched_files"
PATCHES_DIR="patches"

# Crea la cartella di output se non esiste
mkdir -p "$PATCHES_DIR"

# Itera su tutti i file nella cartella unpatched
for unpatched_file in "$UNPATCHED_DIR"/*; do
    filename=$(basename "$unpatched_file")
    patched_file="$PATCHED_DIR/$filename"
    
    # Controlla che il file modificato esista
    if [ -f "$patched_file" ]; then
        # Crea la patch
        diff -u "$unpatched_file" "$patched_file" > "$PATCHES_DIR/$filename.patch"
        echo "[OK]	Patch generated: $PATCHES_DIR/$filename.patch"
    else
        echo "[ERROR]	File not found in folder patched_files: $filename"
    fi
done

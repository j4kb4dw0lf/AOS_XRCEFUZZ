#!/bin/bash

# Cartelle di input/output
UNPATCHED_DIR="unpatched-files"
PATCHED_DIR="patched-files"
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
        echo "Patch generata: $PATCHES_DIR/$filename.patch"
    else
        echo "⚠️  File non trovato nella cartella patched-files: $filename"
    fi
done

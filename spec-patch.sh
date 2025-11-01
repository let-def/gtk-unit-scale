#!/bin/bash
# update_spec.sh
#
# Apply necessary changes to GTK3/GTK4 RPM .spec file.
#
# Usage: ./update_spec.sh /path/to/gtk3.spec patch-file-name.patch

SPEC_FILE=$1
NEW_PATCH_LINE=$2

if [ -z "$SPEC_FILE" ]; then
    echo "Error: Please provide the path to the .spec file."
    echo "Usage: $0 /path/to/your.spec patch-file-name.patch"
    exit 1
fi

if [ -z "$NEW_PATCH_LINE" ]; then
    echo "Error: Please provide the path to the .spec file."
    echo "Usage: $0 /path/to/your.spec patch-file-name.patch"
    exit 1
fi

if [ ! -f "$SPEC_FILE" ]; then
    echo "Error: File not found at '$SPEC_FILE'."
    exit 1
fi

echo "Processing $SPEC_FILE..."
SUCCESS=true

# --- 1. Add %define localrelease .unit_scale ---
# Anchor: Insert the new define after the initial conditional block (%endif)

if grep -q "%define localrelease" "$SPEC_FILE"; then
    echo "  -> '%define localrelease' already exists. Skipping insertion."
else
    # Find the line number of the first '%global' or '%define' that follows '%endif'
    # or just look for the first %global, which is usually a safe anchor.
    ANCHOR_LINE=$(grep -n -m 1 "%global glib2_version" "$SPEC_FILE" | cut -d: -f1)

    if [ -n "$ANCHOR_LINE" ]; then
        # Insert the new define line and a blank line before the anchor
        sed -i "${ANCHOR_LINE}i\\
%define localrelease .unit_scale\\
" "$SPEC_FILE"
        echo "  -> Added '%define localrelease .unit_scale'."
    else
        echo "  -> Error: Could not find anchor line for localrelease insertion."
        SUCCESS=false
    fi
fi


# --- 2. Update the Release line ---
# Target: Release: 2%{?dist} -> Release: 2%{?dist}%localrelease

if grep -q "Release:.*%localrelease" "$SPEC_FILE"; then
    echo "  -> 'Release' line already updated. Skipping modification."
else
    sed -i 's/^Release: .*$/&%localrelease/' "$SPEC_FILE"
    if [ $? -eq 0 ]; then
        echo "  -> Updated Release line."
    else
        echo "  -> Error: Could not update Release line."
        SUCCESS=false
    fi
fi


# --- 3. Add PatchXX: patch-file-name.patch ---

# Find the next available patch number
LAST_PATCH=$(grep -E '^Patch[0-9]+:' "$SPEC_FILE" | tail -n 1)

if echo "$LAST_PATCH" | grep -q "$NEW_PATCH_LINE"; then
    echo "  -> Patch line for '$NEW_PATCH_LINE' already exists. Skipping insertion."
else
    if [ -z "$LAST_PATCH" ]; then
        NEXT_PATCH_NUM=1
    else
        # Extract the number and increment it
        NUM_STR=$(echo "$LAST_PATCH" | grep -oE 'Patch[0-9]+' | grep -oE '[0-9]+')
        NEXT_PATCH_NUM=$((NUM_STR + 1))
    fi

    # Format the next patch number (e.g., 3 -> 03)
    NEXT_PATCH_LABEL=$(printf "Patch%02d" $NEXT_PATCH_NUM)
    NEW_PATCH_ENTRY="${NEXT_PATCH_LABEL}: ${NEW_PATCH_LINE}"

    # Insert the new patch line before the first BuildRequires line
    ANCHOR_LINE=$(grep -n -m 1 "BuildRequires:" "$SPEC_FILE" | cut -d: -f1)

    if [ -n "$ANCHOR_LINE" ]; then
        # Insert the new patch line 1 line before the BuildRequires line
        sed -i "$(($ANCHOR_LINE - 1))a\\
${NEW_PATCH_ENTRY}
" "$SPEC_FILE"
        echo "  -> Added new patch line: ${NEW_PATCH_ENTRY}"
    else
        echo "  -> Error: Could not find 'BuildRequires:' anchor for patch insertion."
        SUCCESS=false
    fi
fi

if $SUCCESS; then
    echo ""
    echo "All requested modifications applied successfully to $SPEC_FILE."
    exit 0
else
    echo ""
    echo "One or more modifications failed. Please check the output and the file manually."
    exit 1
fi

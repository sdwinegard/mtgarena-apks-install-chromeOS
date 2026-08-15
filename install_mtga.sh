#!/system/bin/sh

# ========================================================
# CONFIGURATION
# --- DOWNLOAD DIRECTORY ---
DOWNLOAD_DIR="/sdcard/Download/magic"
SOURCE_FILE="/sdcard/Download/magic.zip"
# ========================================================

echo "--- Starting MTG Arena Installation Automation ---"

TOTAL_SIZE=0
APK_PATHS="" # Variable to hold the list of paths found
APK_DATA=()  # Indexed array to store {path: size} pairs
INDEX=0      # Loop counter for staging index (0, 1, 2...)
FOUND_COUNT=0 # Counter for how many APKs were actually processed

# Step 1: Unzip zip file
echo "[STEP 1/6] Unzipping source file APKs to $DOWNLOAD_DIR..."
unzip -d "$DOWNLOAD_DIR" "$SOURCE_FILE"

# Step 2: Calculate total size and list files (Revised Portable Method)
echo "[STEP 2/6] Calculating sizes and finding APKs in $DOWNLOAD_DIR..."

# Initialize an array to hold the paths found by globbing.
# Using a simple loop structure for maximum portability.
apk_paths=("$DOWNLOAD_DIR"/*.apk)

for apk_path in "${apk_paths[@]}"; do
    # Check if the globbing actually returned a file (handles cases where no files exist)
    if [ -f "$apk_path" ]; then
        # Use stat to get file size in bytes.
        APK_SIZE=$(stat -c%s "$apk_path") 
        TOTAL_SIZE=$((TOTAL_SIZE + APK_SIZE))
        
        # Store the path and size together for easy access
        APK_DATA[${FOUND_COUNT}]="$apk_path $APK_SIZE"
        FOUND_COUNT=$((FOUND_COUNT + 1))
    fi
done

if [ $FOUND_COUNT != 3 ]; then
	echo "Error: No .apk files or improper amount of them found in $DOWNLOAD_DIR. Found: $FOUND_COUNT apk file(s). Please verify the directory path, contents."
    exit 1
fi

echo "Total APK file count found: ${FOUND_COUNT}"
echo "Calculated total package size: $TOTAL_SIZE bytes."


# Step 3: Create Installation Session (pm install-create)
echo "[STEP 3/6] Creating new installation session with $TOTAL_SIZE bytes..."

# Execute the create command and capture output to find the Session ID
CREATE_OUTPUT=$(pm install-create -S "$TOTAL_SIZE")
# Extract potential numeric IDs for the session ID.
SESSION_ID=$(echo "$CREATE_OUTPUT" | grep -oE '[0-9]+' | head -1)

if [ -z "$SESSION_ID" ]; then
    echo "Error: Could not retrieve a valid installation session ID. Aborting."
    exit 1
fi

echo "Success: Created install session ID: $SESSION_ID"


# Step 4: Stage all APK files and commit (pm install-write & pm install-commit)
echo "[STEP 4/6] Staging all APK components to session $SESSION_ID..."

CURRENT_INDEX=0 # Reset the index for staging
for data_entry in "${APK_DATA[@]}"; do
    # Split the stored pair: path is first word, size is second
    read -r apk_path apk_size <<< "$data_entry"

    echo "Writing component $CURRENT_INDEX (Size: $apk_size bytes) from $apk_path..."

    # Stage the file using write command
    cat "$apk_path" | pm install-write -S "$apk_size" "$SESSION_ID" "$CURRENT_INDEX"

    CURRENT_INDEX=$((CURRENT_INDEX + 1))
done


echo "[STEP 5/6] Committing all staged files for installation..."
pm install-commit "$SESSION_ID"

echo "[STEP 6/6] Cleanup and remove $DOWNLOAD_DIR"
rm -fr "$DOWNLOAD_DIR"

echo "--- Installation Process Complete ---"

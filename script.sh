#!/bin/sh

# Function to show an error message and exit
error_exit() {
    yad --title="Error" --text="$1" --button=OK:1
    exit 1
}

# Select disk image
image=$(yad --file --title="Select Disk Image to Flash" --file-filter="Disk images | *.img *.iso" --button="Close:1" --button="Next:0")
if [ $? -ne 0 ]; then
    exit 0
fi

# Prompt for geom name
geom_list=$(geom disk list || error_exit "Failed to list geom disks.")
geom=$(yad --title="Select Drive to Flash" \
    --form \
    --text="Type out the geom name of the drive you want to flash (e.g., /dev/da0). Below is the output of 'geom disk list':\n\n$geom_list" \
    --field="Drive name:":CBE --button=Cancel:1 --button=OK:0 "/dev/")
if [ $? -ne 0 ]; then
    exit 0
fi

# Sanitize the geom input (trim spaces and special characters)
geom=$(echo "$geom" | xargs) # Remove leading/trailing whitespace
geom=$(echo "$geom" | tr -d '|') # Remove unexpected pipe character

# Ask if user wants progress
choice=$(yad --title="Show Progress?" --text="Would you like to show progress during the flash process?" \
    --button=Yes:0 --button=No:2 --button=Cancel:1)
case $? in
    0) status="status=progress";;
    2) status="";;
    1) exit 0;;
    *) exit 1;;
esac

# Build the dd command
dd_command="dd if=\"$image\" of=\"$geom\" bs=1m conv=sync $status"

# Echo the dd command to the terminal
echo "Executing: $dd_command"

# Start flashing process
if [ "$status" = "status=progress" ]; then
    # Run dd and display output in a YAD text box
    (
        echo "Flashing started..."
        eval "$dd_command" 2>&1 | while IFS= read -r line; do
            echo "$line"  # Echo progress to terminal
            echo "$line"  # Output progress to YAD text box
        done
    ) | yad --title="Flashing in Progress" --text-info --width=500 --height=400
else
    # Run dd without progress
    echo "Flashing started. This may take some time."
    eval "$dd_command" || error_exit "Flashing failed."
fi

# Final success message
yad --title="Success" --text="Flash successfully completed!\n\nThanks for using DDGUI." --button=OK:0


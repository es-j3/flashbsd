#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this as root, pretty please."
    exit 1
fi

error_exit() {
    yad --title="Error" --text="$1" --button=OK:1
    exit 1
}

image=$(yad --file --title="Select Disk Image to Flash" --file-filter="Disk images | *.img *.iso" --button="Close:1" --button="Next:0")
if [ $? -ne 0 ]; then
    exit 0
fi
geom_list=$(geom disk list | awk '/Geom name:/ {printf "%s ", $0; next} 1' | fmt -w 80)

geom=$(yad --title="Select Drive to Flash" \
    --form \
    --text="Type out the geom name of the drive you want to flash (e.g., /dev/da0). Below is the output of 'geom disk list':\n\n$geom_list" \
    --field="Drive name:":CBE --button=Cancel:1 --button=OK:0 "/dev/" \
    --text-align=center --fontname="Monospace 10")
if [ $? -ne 0 ]; then
    exit 0
fi

geom=$(echo "$geom" | xargs) # Remove leading/trailing whitespace
geom=$(echo "$geom" | tr -d '|') # Remove unexpected pipe character

choice=$(yad --title="Show Progress?" --text="Would you like to show progress during the flash process?" \
    --button=Yes:0 --button=No:2 --button=Cancel:1)
case $? in
    0) status="status=progress";;
    2) status="";;
    1) exit 0;;
    *) exit 1;;
esac

dd_command="dd if=\"$image\" of=\"$geom\" bs=1m conv=sync $status"

echo "Executing: $dd_command"

if [ "$status" = "status=progress" ]; then
    (
        echo "Flashing started..."
        eval "$dd_command" 2>&1 | while IFS= read -r line; do
            echo "$line" 
            echo "$line" 
        done
    ) | yad --title="Flashing in Progress" --text-info --width=500 --height=400
else
    echo "Flashing started. This may take some time."
    eval "$dd_command" || error_exit "Flashing failed."
fi

yad --title="Success" --text="Flash successfully completed!\n\nThanks for using FlashBSD." --button=OK:0

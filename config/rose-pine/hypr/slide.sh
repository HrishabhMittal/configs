
#!/bin/bash
# Path to the wallpaper folder
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Duration between changes (in seconds)
DURATION=60

while true; do
    # Loop through each image in the folder
    for img in "$WALLPAPER_DIR"/*; do
        hyprctl hyprpaper wallpaper "eDP-1,$img"
        sleep $DURATION
    done
done

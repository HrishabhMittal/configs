
# Path to the directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/gruvbox"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Start fresh by clearing the config file and adding new preload entries
echo "# Hyprpaper Configuration for Wallpaper Slideshow" > "$CONFIG_FILE"
for img in "$WALLPAPER_DIR"/*.{jpg,png,jpeg}; do
    # Add each image file to preload, if it exists
    [ -e "$img" ] && echo "preload = $img" >> "$CONFIG_FILE"
done

# Set the initial wallpaper
echo "wallpaper = eDP-1,$WALLPAPER_DIR/$(ls "$WALLPAPER_DIR" | head -n 1)" >> "$CONFIG_FILE"

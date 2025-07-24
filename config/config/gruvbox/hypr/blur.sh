
#!/bin/bash
# Desired geometry of your dashboard (from hyprctl layers)
DASHBOARD_GEOM="437 155 1046 806"
RULES_FILE="$HOME/.config/hypr/auto-blur.conf"

# Step 1: Find the PID of the layer with matching geometry
dashboard_pid=$(hyprctl layers | grep dashboard | awk '{print $11}')
# Step 2: If found, apply dynamic windowrule
if [[ -n "$dashboard_pid" ]]; then
    echo "Found dashboard PID: $dashboard_pid"

    echo "windowrulev2 = blur,pid:$dashboard_pid" > "$RULES_FILE"
    echo "windowrulev2 = opacity 0.85 0.85,pid:$dashboard_pid" >> "$RULES_FILE"

    # Reload Hyprland configuration (only windowrules)
    hyprctl reload
else
    echo "Dashboard not found"
fi

#!/bin/bash

## If alacritty.yml does not exist, raise an alert
[[ ! -f ~/.config/alacritty/alacritty.toml ]] && \
    notify-send "alacritty.toml does not exist" && exit 0

## Fetch background_opacity from alacritty.toml
opacity=$(awk '/opacity/ {print $3}' $HOME/.config/alacritty/alacritty.toml)
echo opacity is $opacity
## Assign toggle opacity value
case $opacity in
  1.0)
    toggle_opacity=0.9
    ;;
  *)
    toggle_opacity=1.0
    ;;
esac
echo changing to $toggle_opacity
## Replace opacity value in alacritty.toml
sed -i -- "s/opacity = $opacity/opacity = $toggle_opacity/" \
    $HOME/.config/alacritty/alacritty.toml

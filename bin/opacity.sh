
#!/usr/bin/env bash

#awesome wm
file="$HOME/.config/alacritty/alacritty.toml"
line="$(grep opacity "$file")"
num="$(echo "$line" | awk '{ print $3 }')"
rep=""
if [[ "$num" == "1.0" ]]; then
    rep="0.8"
else
    rep="1.0"
fi
newline="$(echo "$line" | sed "s|$num|$rep|")"
sed -i "s|$line|$newline|" "$file"


# hypr


hypr_file="$HOME/.config/hypr/opacity.conf"
rule='windowrulev2 = opacity 0.9 0.9,class:^(code-oss)$'
if grep -q "#" $hypr_file; then
    echo $rule > $hypr_file
else
    echo "# $rule" > $hypr_file
fi

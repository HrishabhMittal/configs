#!/bin/bash

TMP_FILE="/tmp/dashboard_active"
if [[ -f $TMP_FILE ]]; then
    pid="$(ps aux | grep "python $HOME/.config/hypr/dashboard/config.py" | head -n 1 | awk '{print $2}')"
    kill $pid
    rm "$TMP_FILE"
else
    touch "$TMP_FILE"
    source $HOME/pyenv/general/bin/activate
    python $HOME/.config/hypr/dashboard/config.py
fi

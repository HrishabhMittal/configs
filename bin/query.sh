google_search_link() {
  local input="$*"
  if [[ "$input" =~ ^https?:// ]] || [[ "$input" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$ ]]; then
    if [[ "$input" =~ ^https?:// ]]; then
      echo "$input"
    else
      echo "https://$input"
    fi
  else
    # URL-encode the query (requires jq)
    local encoded
    encoded=$(printf '%s' "$input" | jq -s -R -r @uri)
    echo "https://www.google.com/search?q=$encoded"
  fi
}
brave "$(google_search_link $(GTK_THEME=Rosepine-Dark yad --entry --width=500 --no-buttons))"

# Claude Code status line: reads the session JSON on stdin and prints
# "model  dir (branch)  [bar] used/size tokens".
input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
used=$(jq -r '.context_window.total_input_tokens // 0' <<<"$input")
size=$(jq -r '.context_window.context_window_size // 0' <<<"$input")

# Print a token count in short form: 950, 52k, 1.2M.
human() {
  if (($1 >= 1000000)); then
    awk -v n="$1" 'BEGIN { s = sprintf("%.1f", n / 1000000); sub(/\.0$/, "", s); print s "M" }'
  elif (($1 >= 1000)); then
    printf '%dk' $(($1 / 1000))
  else
    printf '%d' "$1"
  fi
}

branch=""
if [ -n "$dir" ]; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null || true)
fi

out=$(printf '\033[1;35m%s\033[0m \033[1;34m%s\033[0m' "$model" "${dir/#$HOME/\~}")
[ -n "$branch" ] && out+=$(printf ' \033[91m(%s)\033[0m' "$branch")
if [ -n "$ctx" ]; then
  pct=$(printf '%.0f' "$ctx")
  filled=$(((pct + 5) / 10))
  ((filled > 10)) && filled=10
  bar=""
  for ((i = 0; i < 10; i++)); do
    if ((i < filled)); then bar+="█"; else bar+="░"; fi
  done
  if ((pct >= 80)); then color=31; elif ((pct >= 50)); then color=33; else color=32; fi
  out+=$(printf ' \033[%sm%s %s/%s\033[0m' "$color" "$bar" "$(human "$used")" "$(human "$size")")
fi
printf '%s\n' "$out"

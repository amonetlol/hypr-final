#!/usr/bin/env bash
set -euo pipefail

ROFI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RASI="$(readlink -f "$ROFI_DIR/active/screenshot.rasi")"
COLORS="$(readlink -f "$ROFI_DIR/active/shared/colors.rasi")"

background="$(grep 'background:' "$COLORS" | head -1 | awk '{print $2}' | tr -d ';' | sed 's/FF$//')"
accent="$(grep 'accent:' "$COLORS" | head -1 | awk '{print $2}' | tr -d ';' | sed 's/FF$//')"

prompt='Screenshot'
mesg="Directory :: $(xdg-user-dir PICTURES)/Screenshots"

option_1=' Desktop'
option_2=' Area'
option_3=' Window'
option_4=' in 5s'
option_5=' in 10s'

rofi_cmd() {
  rofi -dmenu -p "$prompt" -mesg "$mesg" -markup-rows -theme "$RASI"
}

run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"
[[ -d "$dir" ]] || mkdir -p "$dir"

notify_view() {
  notify-send -u low 'Copied to clipboard.' 2>/dev/null || true
  paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null || true
  command -v viewnior >/dev/null && viewnior "$dir/$file" &
  [[ -e "$dir/$file" ]] && notify-send -u low 'Screenshot saved.' || notify-send -u low 'Screenshot deleted.'
}

countdown() {
  for sec in $(seq "$1" -1 1); do
    notify-send -t 1000 "Taking shot in: $sec"
    sleep 1
  done
}

shotnow() {
  cd "$dir" && sleep 0.5 && grim - | tee "$file" | wl-copy
  notify_view
}

shot5() {
  countdown 5
  sleep 1 && cd "$dir" && grim - | tee "$file" | wl-copy
  notify_view
}

shot10() {
  countdown 10
  sleep 1 && cd "$dir" && grim - | tee "$file" | wl-copy
  notify_view
}

shotwin() {
  w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
  w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed 's/,/x/g')
  cd "$dir" && sleep 0.3 && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
  notify_view
}

shotarea() {
  cd "$dir" && grim -g "$(slurp -b "${background:1}CC" -c "${accent:1}ff" -s "${accent:1}0D" -w 2 && sleep 0.3)" - | tee "$file" | wl-copy
  notify_view
}

run_cmd() {
  case "$1" in
    --opt1) shotnow ;;
    --opt2) shotarea ;;
    --opt3) shotwin ;;
    --opt4) shot5 ;;
    --opt5) shot10 ;;
  esac
}

chosen="$(run_rofi)"
[[ -z "$chosen" ]] && exit 0

case "$chosen" in
  *Desktop*) run_cmd --opt1 ;;
  *Area*)    run_cmd --opt2 ;;
  *Window*)  run_cmd --opt3 ;;
  *5s*)      run_cmd --opt4 ;;
  *10s*)     run_cmd --opt5 ;;
esac

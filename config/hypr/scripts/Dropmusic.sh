#!/usr/bin/env bash
# Dropdown Music Player (ncmpcpp)
# Based on Dropterminal.sh by Kiran George

DEBUG=false
SPECIAL_WS="special:scratchpad"
ADDR_FILE="/tmp/dropdown_music_addr"

# Dropdown size and position configuration (percentages)
WIDTH_PERCENT=75
HEIGHT_PERCENT=60
Y_PERCENT=10

# Animation settings
SLIDE_STEPS=5
SLIDE_DELAY=5

# Parse arguments
if [ "$1" = "-d" ]; then
  DEBUG=true
  shift
fi

MUSIC_CMD="${1:-kitty --class ncmpcpp-dropdown ncmpcpp}"

debug_echo() {
  if [ "$DEBUG" = true ]; then
    echo "$@"
  fi
}

get_window_geometry() {
  local addr="$1"
  hyprctl clients -j | jq -r --arg ADDR "$addr" '.[] | select(.address == $ADDR) | "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
}

animate_slide_down() {
  local addr="$1"
  local target_x="$2"
  local target_y="$3"
  local width="$4"
  local height="$5"

  local start_y=$((target_y - height - 50))
  local step_y=$(((target_y - start_y) / SLIDE_STEPS))

  hyprctl dispatch movewindowpixel "exact $target_x $start_y,address:$addr" >/dev/null 2>&1
  sleep 0.05

  for i in $(seq 1 $SLIDE_STEPS); do
    local current_y=$((start_y + (step_y * i)))
    hyprctl dispatch movewindowpixel "exact $target_x $current_y,address:$addr" >/dev/null 2>&1
    sleep 0.03
  done

  hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$addr" >/dev/null 2>&1
}

animate_slide_up() {
  local addr="$1"
  local start_x="$2"
  local start_y="$3"
  local width="$4"
  local height="$5"

  local end_y=$((start_y - height - 50))
  local step_y=$(((start_y - end_y) / SLIDE_STEPS))

  for i in $(seq 1 $SLIDE_STEPS); do
    local current_y=$((start_y - (step_y * i)))
    hyprctl dispatch movewindowpixel "exact $start_x $current_y,address:$addr" >/dev/null 2>&1
    sleep 0.03
  done
}

get_monitor_info() {
  local monitor_data=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale) \(.name)"')
  if [ -z "$monitor_data" ] || [[ "$monitor_data" =~ ^null ]]; then
    return 1
  fi
  echo "$monitor_data"
}

calculate_dropdown_position() {
  local monitor_info=$(get_monitor_info)

  if [ $? -ne 0 ] || [ -z "$monitor_info" ]; then
    echo "100 100 800 600 fallback-monitor"
    return 1
  fi

  local mon_x=$(echo $monitor_info | cut -d' ' -f1)
  local mon_y=$(echo $monitor_info | cut -d' ' -f2)
  local mon_width=$(echo $monitor_info | cut -d' ' -f3)
  local mon_height=$(echo $monitor_info | cut -d' ' -f4)
  local mon_scale=$(echo $monitor_info | cut -d' ' -f5)
  local mon_name=$(echo $monitor_info | cut -d' ' -f6)

  if [ -z "$mon_scale" ] || [ "$mon_scale" = "null" ] || [ "$mon_scale" = "0" ]; then
    mon_scale="1.0"
  fi

  local logical_width logical_height
  if command -v bc >/dev/null 2>&1; then
    logical_width=$(echo "scale=0; $mon_width / $mon_scale" | bc | cut -d'.' -f1)
    logical_height=$(echo "scale=0; $mon_height / $mon_scale" | bc | cut -d'.' -f1)
  else
    local scale_int=$(echo "$mon_scale" | sed 's/\.//' | sed 's/^0*//')
    if [ -z "$scale_int" ]; then scale_int=100; fi
    logical_width=$(((mon_width * 100) / scale_int))
    logical_height=$(((mon_height * 100) / scale_int))
  fi

  if ! [[ "$logical_width" =~ ^-?[0-9]+$ ]]; then logical_width=$mon_width; fi
  if ! [[ "$logical_height" =~ ^-?[0-9]+$ ]]; then logical_height=$mon_height; fi

  local width=$((logical_width * WIDTH_PERCENT / 100))
  local height=$((logical_height * HEIGHT_PERCENT / 100))
  local y_offset=$((logical_height * Y_PERCENT / 100))
  local x_offset=$(((logical_width - width) / 2))

  local final_x=$((mon_x + x_offset))
  local final_y=$((mon_y + y_offset))

  echo "$final_x $final_y $width $height $mon_name"
}

CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

get_window_address() {
  if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
    cut -d' ' -f1 "$ADDR_FILE"
  fi
}

get_window_monitor() {
  if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
    cut -d' ' -f2- "$ADDR_FILE"
  fi
}

window_exists() {
  local addr=$(get_window_address)
  if [ -n "$addr" ]; then
    hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR)' >/dev/null 2>&1
  else
    return 1
  fi
}

window_in_special() {
  local addr=$(get_window_address)
  if [ -n "$addr" ]; then
    hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR and .workspace.name == "special:scratchpad")' >/dev/null 2>&1
  else
    return 1
  fi
}

spawn_window() {
  debug_echo "Creating new dropdown music player"

  local pos_info=$(calculate_dropdown_position)
  local target_x=$(echo $pos_info | cut -d' ' -f1)
  local target_y=$(echo $pos_info | cut -d' ' -f2)
  local width=$(echo $pos_info | cut -d' ' -f3)
  local height=$(echo $pos_info | cut -d' ' -f4)
  local monitor_name=$(echo $pos_info | cut -d' ' -f5)

  local windows_before=$(hyprctl clients -j)
  local count_before=$(echo "$windows_before" | jq 'length')

  hyprctl dispatch exec "[float; size $width $height; workspace special:scratchpad silent] $MUSIC_CMD"

  sleep 0.2

  local windows_after=$(hyprctl clients -j)
  local count_after=$(echo "$windows_after" | jq 'length')

  local new_addr=""

  if [ "$count_after" -gt "$count_before" ]; then
    new_addr=$(comm -13 \
      <(echo "$windows_before" | jq -r '.[].address' | sort) \
      <(echo "$windows_after" | jq -r '.[].address' | sort) |
      head -1)
  fi

  if [ -z "$new_addr" ] || [ "$new_addr" = "null" ]; then
    new_addr=$(hyprctl clients -j | jq -r 'sort_by(.focusHistoryID) | .[-1] | .address')
  fi

  if [ -n "$new_addr" ] && [ "$new_addr" != "null" ]; then
    echo "$new_addr $monitor_name" >"$ADDR_FILE"
    sleep 0.2

    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$new_addr"
    hyprctl dispatch pin "address:$new_addr"
    animate_slide_down "$new_addr" "$target_x" "$target_y" "$width" "$height"

    return 0
  fi

  return 1
}

# Main logic
if window_exists; then
  WINDOW_ADDR=$(get_window_address)
  debug_echo "Found existing music player: $WINDOW_ADDR"

  focused_monitor=$(get_monitor_info | awk '{print $6}')
  dropdown_monitor=$(get_window_monitor)

  if [ "$focused_monitor" != "$dropdown_monitor" ]; then
    pos_info=$(calculate_dropdown_position)
    target_x=$(echo $pos_info | cut -d' ' -f1)
    target_y=$(echo $pos_info | cut -d' ' -f2)
    width=$(echo $pos_info | cut -d' ' -f3)
    height=$(echo $pos_info | cut -d' ' -f4)
    monitor_name=$(echo $pos_info | cut -d' ' -f5)
    hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$WINDOW_ADDR"
    hyprctl dispatch resizewindowpixel "exact $width $height,address:$WINDOW_ADDR"
    echo "$WINDOW_ADDR $monitor_name" >"$ADDR_FILE"
  fi

  if window_in_special; then
    debug_echo "Bringing music player from scratchpad"

    pos_info=$(calculate_dropdown_position)
    target_x=$(echo $pos_info | cut -d' ' -f1)
    target_y=$(echo $pos_info | cut -d' ' -f2)
    width=$(echo $pos_info | cut -d' ' -f3)
    height=$(echo $pos_info | cut -d' ' -f4)

    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$WINDOW_ADDR"
    hyprctl dispatch pin "address:$WINDOW_ADDR"
    hyprctl dispatch resizewindowpixel "exact $width $height,address:$WINDOW_ADDR"
    animate_slide_down "$WINDOW_ADDR" "$target_x" "$target_y" "$width" "$height"
    hyprctl dispatch focuswindow "address:$WINDOW_ADDR"
  else
    debug_echo "Hiding music player to scratchpad"

    geometry=$(get_window_geometry "$WINDOW_ADDR")
    if [ -n "$geometry" ]; then
      curr_x=$(echo $geometry | cut -d' ' -f1)
      curr_y=$(echo $geometry | cut -d' ' -f2)
      curr_width=$(echo $geometry | cut -d' ' -f3)
      curr_height=$(echo $geometry | cut -d' ' -f4)

      animate_slide_up "$WINDOW_ADDR" "$curr_x" "$curr_y" "$curr_width" "$curr_height"
      sleep 0.1
      hyprctl dispatch pin "address:$WINDOW_ADDR"
      hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$WINDOW_ADDR"
    else
      hyprctl dispatch pin "address:$WINDOW_ADDR"
      hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$WINDOW_ADDR"
    fi
  fi
else
  debug_echo "No existing music player found, creating new one"
  if spawn_window; then
    WINDOW_ADDR=$(get_window_address)
    if [ -n "$WINDOW_ADDR" ]; then
      hyprctl dispatch focuswindow "address:$WINDOW_ADDR"
    fi
  fi
fi

#!/bin/sh
# Begin the i3bar (Swaybar) protocol.
echo '{"version": 1}'
echo '['
echo '[],'

# Set the icons.
SCRATCH_ICON=$'\ueb23'  # Nerd Font two-windows icon
CLOCK_ICON=""          # Nerd Font clock icon

while true; do
    # --- Scratchpad Block ---
    # Count windows in the scratchpad by locating the scratchpad container.
    SCRATCH_COUNT=$(swaymsg -t get_tree | jq '[recurse(.nodes[]?, .floating_nodes[]?) | select(.name == "__i3_scratch") | .floating_nodes[]?] | length')
    if [ -z "$SCRATCH_COUNT" ]; then
        SCRATCH_COUNT=0
    fi
    SCRATCH_TEXT="${SCRATCH_ICON} ${SCRATCH_COUNT} | "

    # --- Battery Block ---
    BATTERY=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | awk '/percentage:/ {print $2}')
    POWER_STATUS=$(upower -i /org/freedesktop/UPower/devices/line_power_AC 2>/dev/null | awk '/online:/ {print $2}')
    
    if upower -e 2>/dev/null | grep -q 'battery_BAT0'; then
        if [ "$POWER_STATUS" = "yes" ]; then
            BAT_TEXT=" AC Power |  $BATTERY"
        else
            BAT_TEXT=" $BATTERY"
        fi
    else
        BAT_TEXT=" AC Power"
    fi

    # --- Time Block ---
    DATE=$(date +'%Y-%m-%d %H:%M:%S')
    TIME_TEXT=" | ${CLOCK_ICON} $DATE "

    # Output three blocks (scratchpad, battery, time) in a JSON array.
    echo "[{\"name\": \"scratchpad\", \"full_text\": \"${SCRATCH_TEXT}\", \"separator\": false, \"separator_block_width\": 0}, {\"name\": \"battery\", \"full_text\": \"${BAT_TEXT}\", \"separator\": false, \"separator_block_width\": 0}, {\"name\": \"time\", \"full_text\": \"${TIME_TEXT}\", \"separator\": false, \"separator_block_width\": 0}],"
    
    sleep 1
done

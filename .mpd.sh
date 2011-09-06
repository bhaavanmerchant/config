MPD="$(mpc | head -n 2 | tr '\n' ' ' | sed 's/^\(.*\)\( \[.*\)/\1/')"
MPD_STATE="$(mpc | head -n 2 | tr '\n' ' ' | grep -oG '\[.*\]')"
if [ -z "$MPD" ]; then
echo "<fc=#ff5500>Not Playing</fc>"
else
if [ "$MPD_STATE" = "[paused]" ]; then
echo "<fc=#ff5500>$MPD</fc>"
    elif [ -z "$MPD_STATE" ]; then
echo "<fc=#ff5500>Not Playing</fc>"
    else
echo "<fc=#0055ff>$MPD</fc>"
    fi
fi

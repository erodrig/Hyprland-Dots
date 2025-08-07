#!/bin/bash

# Simple toggle using a temp file as a flag
FLAGFILE="/tmp/nerd-dictation-running"

if [ -f "$FLAGFILE" ]; then
    # If flag exists, end dictation and remove flag
    nerd-dictation end
    rm "$FLAGFILE"
else
    # If no flag, start dictation and create flag
    touch "$FLAGFILE"
    nerd-dictation begin --simulate-input-tool YDOTOOL
fi

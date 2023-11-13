#!/bin/bash

check_for_prohibited_media_files() {
    local prohibited_files

    # Recursively search for prohibited file types
    prohibited_files=$(find / -type f \( -name "*.mp3" -o -name "*.mp4" -o -name "*.avi" -o -name "*.mov" -o -name "*.ogg" \) 2>/dev/null)

    if [[ -n "$prohibited_files" ]]; then
        write_audit_report "Prohibited File" "Prohibited media files found: $prohibited_files"
    fi
    # No action is taken if no prohibited files are found
}

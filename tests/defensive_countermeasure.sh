#!/bin/bash

check_ufw_status() {

if ! command -v ufw &> /dev/null; then
    write_audit_report "Defensive Countermeasure" "UFW not installed"
elif ! ufw status | grep -q "Status: active"; then
    write_audit_report "Defensive Countermeasure" "UFW is not enabled"
fi
}

check_clamav_status() {
    local clamav_installed=false
    local clamav_active=false

    # Check if ClamAV is installed
    if command -v clamscan &> /dev/null; then
        clamav_installed=true

        # Check if ClamAV daemon (clamd) is active
        if systemctl is-active --quiet clamav-daemon; then
            clamav_active=true
        fi
    fi

    # Reporting based on the status
    if [[ "$clamav_installed" = false ]]; then
        write_audit_report "Defensive Countermeasure" "ClamAV is not installed"
    elif [[ "$clamav_installed" = true && "$clamav_active" = false ]]; then
        write_audit_report "Defensive Countermeasure" "ClamAV is installed but not active"
    fi
    # No action is taken if ClamAV is installed and active
}

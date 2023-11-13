#!/bin/bash

check_apt_upgradable_packages() {
    local upgradable_count

    # Updating package lists to get the latest information
    sudo apt-get update &> /dev/null

    # Getting the count of upgradable packages
    upgradable_count=$(apt list --upgradable 2>/dev/null | grep -c upgradable)

    if [[ "$upgradable_count" -ne 0 ]]; then
        write_audit_report "Application Update" "$upgradable_count packages can be upgraded"
    fi
    # No action is taken if there are no upgradable packages
}

check_held_packages() {
    local held_packages

    # Getting the list of held packages
    held_packages=$(dpkg --get-selections | grep 'hold$' | awk '{print $1}')

    if [[ -n "$held_packages" ]]; then
        write_audit_report "Application Update" "Packages with a hold: $held_packages"
    fi
    # No action is taken if there are no packages on hold
}

check_snap_updates() {
    local updatable_snaps

    # Getting the list of snap packages that can be updated
    updatable_snaps=$(snap list --all | awk '/v.*\s+snapd\s+/ {if ($6 != "disabled" && $7 == "refresh-available") print $1}')

    if [[ -n "$updatable_snaps" ]]; then
        write_audit_report "Application Update" "Snap packages needing update: $updatable_snaps"
    fi
    # No action is taken if there are no snap packages to update
}

#!/bin/bash

check_unsafe_running_services() {
    # Define the list of safe services
    local safe_services=("sshd" "networking" "crond" "accounts-daemon" "acpid" "avahi-daemon" "colord" "cron" "cups-browsed" "cups" "dbus" "fwupd" "gdm" "irqbalance" "kerneloops" "ModemManager" "networkd-dispatcher" "NetworkManager" "open-vm-tools" "packagekit" "polkit" "power-profiles-daemon" "rtkit-daemon" "snapd" "fprintd" "switcheroo-control" "systemd-journald" "systemd-logind" "systemd-oomd" "systemd-resolved" "systemd-timesyncd" "systemd-udevd" "udisks2" "unattended-upgrades" "upower" "vgauth" "wpa_supplicant" "LOAD" "ACTIVE" "SUB" "45" ... ) # Add your safe services here

    # Get a list of all running services
    local running_services=($(systemctl list-units --type=service --state=running | awk '{print $1}' | sed '1,1d'))

    # Compare running services with the safe services
    for service in "${running_services[@]}"; do
        if [[ ! " ${safe_services[*]} " =~ " ${service%%.*} " ]]; then
            write_audit_report "Service Auditing" "Unsafe running service detected: $service"
        fi
    done
}

#!/bin/bash

check_ubuntu_sources() {
    local distro=$(lsb_release -is)
    
    if [[ "$distro" == "Ubuntu" ]]; then
        local missing_sources=()
        local sources_list="/etc/apt/sources.list"
        local sources_list_d="/etc/apt/sources.list.d/*"

        # List of required sources
        local required_sources=("main" "universe" "multiverse" "security")

        for source in "${required_sources[@]}"; do
            if ! grep -R "deb .* $source" $sources_list $sources_list_d &> /dev/null; then
                missing_sources+=("$source")
            fi
        done

        if [ ${#missing_sources[@]} -ne 0 ]; then
            write_audit_report "OS Update" "Missing Ubuntu sources: ${missing_sources[*]}"
        fi
    fi
}

check_debian_sources() {
    local distro=$(lsb_release -is)
    
    if [[ "$distro" == "Debian" ]]; then
        local missing_sources=()
        local sources_list="/etc/apt/sources.list"
        local sources_list_d="/etc/apt/sources.list.d/*"

        # List of required sources for Debian
        local required_sources=("main" "contrib" "non-free" "security")

        for source in "${required_sources[@]}"; do
            if ! grep -R "deb .* $source" $sources_list $sources_list_d &> /dev/null; then
                missing_sources+=("$source")
            fi
        done

        if [ ${#missing_sources[@]} -ne 0 ]; then
            write_audit_report "OS Update" "Missing Debian sources: ${missing_sources[*]}"
        fi
    fi
}

check_apt_periodic_settings() {
    local apt_periodic_file="/etc/apt/apt.conf.d/10periodic"
    local settings_mismatched=()

    # Define the required settings and their expected values
    declare -A required_settings=(
        ["APT::Periodic::Update-Package-Lists"]="1"
        ["APT::Periodic::Download-Upgradeable-Packages"]="1"
        ["APT::Periodic::AutocleanInterval"]="7"
        ["APT::Periodic::Unattended-Upgrade"]="1"
    )

    # Check each setting in the file
    for setting in "${!required_settings[@]}"; do
        local expected_value="${required_settings[$setting]}"
        local actual_value=$(grep "^$setting" "$apt_periodic_file" | awk '{print $2}' | tr -d '";')

        if [[ "$actual_value" != "$expected_value" ]]; then
            settings_mismatched+=("$setting (Expected: $expected_value, Found: $actual_value)")
        fi
    done

    # Report any mismatched settings
    if [[ ${#settings_mismatched[@]} -gt 0 ]]; then
        write_audit_report "OS Update" "Mismatched settings in $apt_periodic_file: ${settings_mismatched[*]}"
    fi
}










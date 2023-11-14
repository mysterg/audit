#!/bin/bash

check_sshd_config() {
    # Check if openssh-server is installed
    if ! dpkg -l | grep -qw openssh-server; then
        write_audit_report "Application Security" "openssh-server is not installed"
        return
    fi

    local sshd_config_file="/etc/ssh/sshd_config"
    declare -A required_configs=(
        ["PermitRootLogin"]="no"
        ["Protocol"]="2"
        ["PrintLastLog"]="no"
        ["ListenAddress"]="127.0.0.1"
        ["PasswordAuthentication"]="no"
        ["IgnoreRhosts"]="yes"
        ["RhostsAuthentication"]="no"
        ["RSAAuthentication"]="yes"
        ["HostbasedAuthentication"]="no"
        ["LoginGraceTime"]="60"
        ["MaxStartups"]="2"
        ["AllowTcpForwarding"]="no"
        ["X11Forwarding"]="no"
        ["LogLevel"]="VERBOSE"
        ["PermitEmptyPasswords"]="no"
        ["ClientAliveInterval"]="300"
        ["ClientAliveCountMax"]="0"
        ["PermitUserEnvironment"]="no"
        ["AllowAgentForwarding"]="no"
    )

    for key in "${!required_configs[@]}"; do
        local expected_value="${required_configs[$key]}"
        local actual_value=$(grep "^$key" "$sshd_config_file" | awk '{print $2}')

        if [[ "$actual_value" != "$expected_value" ]]; then
            write_audit_report "Application Security" "$key setting mismatch (Expected: $expected_value, Found: $actual_value)"
        fi
    done
}


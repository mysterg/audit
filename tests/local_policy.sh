#!/bin/bash

check_pass_max_days() {
    local pass_max_days=$(awk '/^PASS_MAX_DAYS/ {print $2}' /etc/login.defs)

    if [[ -z "$pass_max_days" ]]; then
        write_audit_report "Account Policy" "PASS_MAX_DAYS setting not found in /etc/login.defs"
    elif (( pass_max_days < 30 || pass_max_days > 90 )); then
        write_audit_report "Account Policy" "PASS_MAX_DAYS setting is outside the recommended range (30-90): $pass_max_days"
    fi
    # No action is taken if the setting is within the recommended range
}


check_pass_min_days() {
    local pass_min_days=$(awk '/^PASS_MIN_DAYS/ {print $2}' /etc/login.defs)

    if [[ -z "$pass_min_days" ]]; then
        write_audit_report "Account Policy" "PASS_MIN_DAYS setting not found in /etc/login.defs"
    elif (( pass_min_days < 2 || pass_min_days > 25 )); then
        write_audit_report "Account Policy" "PASS_MIN_DAYS setting is outside the recommended range (2-25): $pass_min_days"
    fi
    # No action is taken if the setting is within the recommended range
}

check_pam_cracklib() {
    if command -v dpkg &> /dev/null; then
        if ! dpkg -l | grep -qw pam-cracklib; then
            write_audit_report "Account Policy" "pam-cracklib package is not installed"
        fi
    fi
    # No action is taken if the package is installed or if the system is not Debian-based
}

check_password_encryption() {
    local common_password_file="/etc/pam.d/common-password"
    local encryption_used=$(grep "pam_unix.so" "$common_password_file" | grep -Eo "sha512|yescrypt")
    
    if [[ -z "$encryption_used" ]]; then
        write_audit_report "Account Policy" "Passwords are not being stored in encrypted format (sha512 or yescrypt not found in $common_password_file)"
    fi
    # No action is taken if sha512 or yescrypt is found
}

check_password_remember() {
    local common_password_file="/etc/pam.d/common-password"
    local pam_unix_line=$(grep "pam_unix.so" "$common_password_file")
    local remember_setting=$(echo "$pam_unix_line" | grep -oP 'remember=\K[0-9]+')

    if [[ -z "$remember_setting" ]]; then
        write_audit_report "Account Policy" "Password history (remember) setting not found in $common_password_file"
    elif (( remember_setting <= 9 || remember_setting >= 25 )); then
        write_audit_report "Account Policy" "Password history (remember) setting is out of recommended range (10-24): $remember_setting"
    fi
    # No action is taken if the remember setting is within the recommended range and present
}

check_pwquality_minlen() {
    local pwquality_file="/etc/security/pwquality.conf"
    local minlen_line=$(grep -E "^[^#]*minlen\s*=" "$pwquality_file")
    local minlen_value=$(echo "$minlen_line" | awk -F= '{print $2}' | tr -d ' ')

    if [[ -z "$minlen_line" ]]; then
        write_audit_report "Account Policy" "The minlen setting is not set in $pwquality_file"
    elif (( minlen_value < 12 )); then
        write_audit_report "Account Policy" "The minlen setting in $pwquality_file is less than the recommended value of 12: $minlen_value"
    fi
    # No action is taken if minlen is set and greater than or equal to 12
}

check_blank_passwords_permitted() {
    local common_auth_file="/etc/pam.d/common-auth"

    if grep -q "nullok" "$common_auth_file"; then
        write_audit_report "Account Policy" "Blank passwords permitted in common-auth"
    fi
    # No action is taken if nullok is not present
}

check_password_lockout_policy() {
    local common_auth_file="/etc/pam.d/common-auth"

    if ! grep -q "pam_tally2.so" "$common_auth_file"; then
        write_audit_report "Account Policy" "Password lockout policy not set in common-auth"
    fi
    # No action is taken if pam_tally2.so is present
}


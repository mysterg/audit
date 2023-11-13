#!/bin/bash

# Function to Find All Users with /bin/bash Shell
find_bash_users() {
    local bash_users=$(awk -F: '/\/bin\/bash$/ {print $1}' /etc/passwd | tr '\n' ' ')
    local report_message="Users with /bin/bash shell: $bash_users"

    write_audit_report "User Auditing" "$report_message"
}

# Function to Find All Users in the sudo Group
find_sudo_users() {
    local sudo_users=$(getent group sudo | cut -d: -f4 | tr ',' ' ')
    local report_message="Users in sudo group: $sudo_users"

    write_audit_report "User Auditing" "$report_message"
}

# Function to Check Unencrypted Passwords in /etc/shadow
check_unencrypted_passwords() {
    local unencrypted_users=$(awk -F: '($2 !~ /^\$/ && $2 != "!" && $2 != "*") {print $1}' /etc/shadow)
    local report_message

    if [ ! -z "$unencrypted_users" ]; then
        report_message="Users with unencrypted passwords: $unencrypted_users"
    fi

    write_audit_report "User Auditing" "$report_message"
}

check_password_never_expires() {
    # Join /etc/passwd and /etc/shadow and then filter
    local non_expiring_users=$(join --nocheck-order -t: -o 1.1,1.7,2.5 <(sort /etc/passwd) <(sort /etc/shadow) | awk -F: '($2 == "/bin/bash" && ($3 == "99999")) {print $1}' | tr '\n' ' ')

    if [[ -n "$non_expiring_users" ]]; then
        write_audit_report "User Auditing" "Users with non-expiring passwords: $non_expiring_users"
    fi
}



check_non_root_uid0_users() {
    local non_root_uid0_users=$(awk -F: '($3 == "0" && $1 != "root") {print $1}' /etc/passwd)
    
    if [[ -n "$non_root_uid0_users" ]]; then
        write_audit_report "User Auditing" "Non-root users with UID 0: $non_root_uid0_users"
    fi
}

check_low_id_users_with_shells() {
    local users_with_shells=$(awk -F: '($3 > 0 && $3 <= 999 && ($7 == "/bin/bash" || $7 == "/bin/sh")) {print $1}' /etc/passwd)

    if [[ -n "$users_with_shells" ]]; then
        write_audit_report "User Auditing" "System accounts with usable shell: $users_with_shells"
    fi
}







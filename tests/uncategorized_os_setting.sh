#!/bin/bash

check_etc_shadow_permissions() {
    local shadow_file="/etc/shadow"
    local file_owner=$(stat -c "%U" "$shadow_file")
    local file_perms=$(stat -c "%A" "$shadow_file")

    if [[ "$file_owner" != "root" ]]; then
        write_audit_report "Uncategorized OS Setting" "The owner of $shadow_file is not root"
    elif [[ "$file_perms" != *"------"* ]]; then
        write_audit_report "Uncategorized OS Setting" "$shadow_file has incorrect permissions (should not be readable by others)"
    fi
    # No action is taken if the owner is root and others have no read access
}

check_etc_passwd_permissions() {
    local passwd_file="/etc/passwd"
    local file_owner=$(stat -c "%U" "$passwd_file")
    local file_perms=$(stat -c "%a" "$passwd_file")

    if [[ "$file_owner" != "root" ]]; then
        write_audit_report "Uncategorized OS Setting" "The owner of $passwd_file is not root"
    elif [[ "$file_perms" != "644" ]]; then
        write_audit_report "Uncategorized OS Setting" "Permissions for $passwd_file are not set to 644 (Current: $file_perms)"
    fi
    # No action is taken if the owner is root and permissions are 644
}

check_grub_cfg_permissions_and_owner() {
    local grub_cfg_file="/boot/grub/grub.cfg"
    local file_owner=$(stat -c "%U" "$grub_cfg_file")
    local file_perms=$(stat -c "%a" "$grub_cfg_file")

    if [[ "$file_owner" != "root" ]]; then
        write_audit_report "Uncategorized OS Setting" "The owner of $grub_cfg_file is not root"
    elif [[ "$file_perms" != "444" ]]; then
        write_audit_report "Uncategorized OS Setting" "Permissions for $grub_cfg_file are not set to 444"
    fi
}

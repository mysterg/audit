#!/bin/bash

# Global Variables
LOG_FILE="/var/log/linux_security_audit.log"
PUSER=`w -hs | awk '$3 == ":0" {print $1}'`
REPORT_FILE="/home/$PUSER/Desktop/linux_security_audit_report.html"



# Distribution Information
DIST=$(lsb_release -is)
CODENAME=$(lsb_release -sc)
RELEASE=$(lsb_release -sr)

# Logging Setup
setup_logging() {
    touch "$LOG_FILE"
    exec 1> >(tee -a "$LOG_FILE") 2>&1
    echo "Logging started at $(date)"
}

# Importing Other Sections
import_sections() {
    source "./tests/forensic_questions.sh"
    source "./tests/user_auditing.sh"
    source "./tests/account_policy.sh"
    source "./tests/local_policy.sh"
    source "./tests/defensive_countermeasure.sh"
    source "./tests/uncategorized_os_setting.sh"
    source "./tests/service_auditing.sh"
    source "./tests/os_update.sh"
    source "./tests/application_update.sh"
    source "./tests/prohibited_file.sh"
    source "./tests/unwanted_software.sh"
    source "./tests/malware.sh"
    source "./tests/application_security.sh"
    # ... add more imports as needed
}

# Reporting Function
# Function to Write the Head, Title, and Open Body Section
init_report() {
    rm $REPORT_FILE
    echo "<html><head><style>.collapsible-content { margin: 10px 0; overflow: hidden; transition: max-height 0.2s ease-out; }</style><title>Linux Security Audit Report</title></head><body>" > "$REPORT_FILE"
    echo "<h1>Linux Security Audit Report</h1>" >> "$REPORT_FILE"
    echo "<p><strong>Date:</strong> $(date)</p>" >> "$REPORT_FILE"
    echo "<p><strong>Distribution:</strong> $DIST, <strong>Codename:</strong> $CODENAME, <strong>Release:</strong> $RELEASE</p>" >> "$REPORT_FILE"
}

start_collapsible_section() {
    local audit_section="$1"
    echo "<h2>$audit_section</h2>" >> "$REPORT_FILE"
    echo "<div class='collapsible-content'>" >> "$REPORT_FILE"
}

end_collapsible_section() {
    echo "</div>" >> "$REPORT_FILE"
}

# Function to Write the Output of Each Audit to the Body Section
write_audit_report() {
    local audit_section="$1"
    local audit_data="$2"
    #echo "<h2>$audit_section</h2>" >> "$REPORT_FILE"
    echo "<pre>$audit_data</pre>" >> "$REPORT_FILE"
}

# Function to Close the Body and HTML Tags
finalize_report() {
    echo "</body></html>" >> "$REPORT_FILE"
    chmod 777 "$REPORT_FILE"
    chown $PUSER $REPORT_FILE
}

# Main Execution
main() {
    setup_logging
    import_sections
    init_report

    # Call functions from imported sections here
    start_collapsible_section "Forensic Questions"
	check_forensic_question 1
	check_forensic_question 2
	check_forensic_question 3
    end_collapsible_section
	
    start_collapsible_section "User Auditing"
	find_bash_users
	find_sudo_users
	check_unencrypted_passwords
	check_password_never_expires
	check_non_root_uid0_users
	check_low_id_users_with_shells
    end_collapsible_section
	
    start_collapsible_section "Local Policy"
	check_pass_max_days
	check_pass_min_days
	check_libpam_pwquality
	check_password_encryption
	check_password_remember
	check_pwquality_minlen
    check_blank_passwords_permitted
    check_password_lockout_policy
    end_collapsible_section

    start_collapsible_section "Defensive Countermeasure"
    check_ufw_status
    check_clamav_status
    end_collapsible_section

    start_collapsible_section "Uncategorized OS"
    check_etc_shadow_permissions
    check_etc_passwd_permissions
    check_grub_cfg_permissions_and_owner
    end_collapsible_section

    start_collapsible_section "Service Auditing"
    check_unsafe_running_services
    end_collapsible_section

    start_collapsible_section "OS Update"
    check_ubuntu_sources
    check_debian_sources
    check_apt_periodic_settings
    end_collapsible_section

    start_collapsible_section "Application Update"
    check_apt_upgradable_packages
    check_held_packages
    check_snap_updates
    end_collapsible_section

    start_collapsible_section "Prohibited File"
    check_for_prohibited_media_files
    end_collapsible_section

    start_collapsible_section "Unwanted Software"
    check_unwanted_software
    end_collapsible_section

    start_collapsible_section "Malware"
    report_listening_services
    check_rkhunter
    end_collapsible_section

    start_collapsible_section "Application Security"
    check_sshd_config
    end_collapsible_section

    finalize_report
    echo "Audit completed. Report saved to $REPORT_FILE"
}

# Run the main function
main

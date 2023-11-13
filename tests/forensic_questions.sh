#!/bin/bash

# Function to Check Forensic Question Based on Argument
check_forensic_question() {
    local question_number="$1"
    local desktop_path="/home/$PUSER/Desktop"
    local question_file="${desktop_path}/Forensic Question ${question_number}.txt"
    local report_message

    if [[ -f "$question_file" ]]; then
        if tail -n 5 "$question_file" | grep -qi 'ANSWER: <Type Answer Here>'; then
            report_message="Forensic Question ${question_number} unanswered"
        fi
    else
        report_message="Forensic Question ${question_number} file not found"
    fi

    write_audit_report "Forensic Questions" "$report_message"
}

# Example Usage
#check_forensic_question 1  # For Forensic Question 1
#check_forensic_question 2  # For Forensic Question 2

#!/bin/bash
# MongoDB Security Audit Tool (Interactive CLI + Email Alerts)
# Based on: https://github.com/stampery/mongoaudit
# Author: Astra
# Version: 2.0
MONGO_CONF="/etc/mongod.conf"
OUTPUT_FILE="mongodb_security_audit.txt"
SMTP_SERVER="smtp.example.com"
EMAIL_TO="admin@example.com"
EMAIL_FROM="audit@example.com"
# Function to send an email alert
send_email() {
    local subject="MongoDB Security Audit Report - $(date)"
    local body=$(cat "$OUTPUT_FILE")
    
    echo -e "Subject: $subject\n\n$body" | sendmail -S "$SMTP_SERVER" -f "$EMAIL_FROM" "$EMAIL_TO"
    
    echo "[✔] Email sent to $EMAIL_TO"
}

# Function to print status messages
status_check() {
    if [[ $? -eq 0 ]]; then
        echo "[✔] $1"
        echo "[✔] $1" >> "$OUTPUT_FILE"
    else
        echo "[✘] $2"
        echo "[✘] $2" >> "$OUTPUT_FILE"
    fi
}

# Interactive CLI Menu
interactive_menu() {
    echo "==================================="
    echo "   MongoDB Security Audit Tool     "
    echo "==================================="
    echo "1. Run Full Security Audit"
    echo "2. Check if MongoDB is Running"
    echo "3. Check Authentication Settings"
    echo "4. Check Open Ports"
    echo "5. Check Anonymous Access"
    echo "6. Check TLS/SSL Configuration"
    echo "7. Send Email Report"
    echo "8. Exit"
    echo "==================================="
    read -p "Choose an option (1-8): " choice

    case $choice in
        1) run_full_audit ;;
        2) check_mongo_running ;;
        3) check_authentication ;;
        4) check_open_ports ;;
        5) check_anonymous_access ;;
        6) check_ssl ;;
        7) send_email ;;
        8) echo "Exiting..."; exit 0;;
        *) echo "Invalid choice! Please select again."; interactive_menu;;
    esac
}

# Function to check if MongoDB is running
check_mongo_running() {
    echo "Checking if MongoDB is running..."
    pgrep mongod > /dev/null
    status_check "MongoDB is running." "MongoDB is NOT running!"
}

# Function to check authentication settings
check_authentication() {
    echo "Checking Authentication Settings..."
    grep -q "authorization: enabled" $MONGO_CONF
    status_check "Authentication is enabled." "Authentication is NOT enabled! Risk: Unauthorized access possible."
}

# Function to check open MongoDB ports
check_open_ports() {
    echo "Checking MongoDB Port Exposure..."
    netstat -tulnp | grep ":27017" > /dev/null
    status_check "MongoDB is running on port 27017." "MongoDB port 27017 is NOT open! Risk: Database may not be accessible."
}

# Function to check anonymous access
check_anonymous_access() {
    echo "Checking for Anonymous Access..."
    mongo --quiet --eval "db.runCommand({connectionStatus: 1})" | grep -q "authInfo"
    status_check "Anonymous access is restricted." "Anonymous access is ALLOWED! Risk: Unauthorized access possible."
}

# Function to check TLS/SSL configuration
check_ssl() {
    echo "Checking for TLS/SSL Encryption..."
    grep -q "ssl:" $MONGO_CONF
    status_check "TLS/SSL is enabled." "TLS/SSL is NOT enabled! Risk: Data may be transmitted unencrypted."
}

# Function to run a full security audit
run_full_audit() {
    echo "===================================" > "$OUTPUT_FILE"
    echo " MongoDB Security Audit Report     " >> "$OUTPUT_FILE"
    echo " Generated on: $(date)             " >> "$OUTPUT_FILE"
    echo "===================================" >> "$OUTPUT_FILE"

    check_mongo_running
    check_authentication
    check_open_ports
    check_anonymous_access
    check_ssl

    echo "===================================" >> "$OUTPUT_FILE"
    echo " Audit completed successfully.      " >> "$OUTPUT_FILE"
    echo "===================================" >> "$OUTPUT_FILE"

    echo "Audit completed. Report saved to $OUTPUT_FILE."

    read -p "Do you want to send the audit report via email? (y/n): " send_email_choice
    if [[ "$send_email_choice" == "y" ]]; then
        send_email
    fi
}

# Run the interactive menu
interactive_menu

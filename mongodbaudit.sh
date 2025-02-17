#!/bin/bash
# MongoDB Security Audit Tool (Interactive CLI + Email Alerts)
# Based on: https://github.com/stampery/mongoaudit
# Author: Astra (Modified and enhanced)
# Version: 2.1

# Install dependencies if not present (more robust)
if ! command -v netstat &> /dev/null; then
  sudo apt install net-tools -y
fi
if ! command -v sendmail &> /dev/null; then
  sudo apt install sendmail -y
fi
if ! command -v mongo &> /dev/null; then
  echo "MongoDB client (mongo) is required. Please install it."
  exit 1
fi

MONGO_CONF="/etc/mongod.conf"
OUTPUT_FILE="mongodb_security_audit.txt"
SMTP_SERVER="smtp.vairavtech.com" # Consider making this configurable
EMAIL_TO="prem@vairavtech.com" # Consider making this configurable
EMAIL_FROM="audit@vairavtech.com" # Consider making this configurable

# Function to send an email alert (improved error handling)
send_email() {
  local subject="MongoDB Security Audit Report - $(date)"
  local body=$(cat "$OUTPUT_FILE")

  if echo -e "Subject: $subject\n\n$body" | sendmail -S "$SMTP_SERVER" -f "$EMAIL_FROM" "$EMAIL_TO"; then
    echo "[✔] Email sent to $EMAIL_TO"
  else
    echo "[✘] Failed to send email. Check sendmail configuration and logs." >> "$OUTPUT_FILE"
    echo "[✘] Failed to send email. Check sendmail configuration and logs."
  fi
}

# Function to print status messages (improved logging)
status_check() {
  local message="$1"
  local status="$2" # "OK" or "WARNING"

  if [[ "$status" == "OK" ]]; then
    echo "[✔] $message"
    echo "[✔] $message" >> "$OUTPUT_FILE"
  elif [[ "$status" == "WARNING" ]]; then
    echo "[✘] $message"
    echo "[✘] $message" >> "$OUTPUT_FILE"
  else
    echo "[?] Unknown status: $status"
    echo "[?] Unknown status: $status" >> "$OUTPUT_FILE"
  fi
}

# Interactive CLI Menu (improved clarity and error handling)
interactive_menu() {
  while true; do
    echo "==================================="
    echo "    MongoDB Security Audit Tool    "
    echo "==================================="
    echo "1. Run Full Security Audit"
    echo "2. Check MongoDB Status"
    echo "3. Check Authentication"
    echo "4. Check Network Exposure"
    echo "5. Check Anonymous Access"
    echo "6. Check TLS/SSL Configuration"
    echo "7. Send Email Report"
    echo "8. Exit"
    echo "==================================="
    read -rp "Choose an option (1-8): " choice

    case "$choice" in
      1) run_full_audit ;;
      2) check_mongo_running ;;
      3) check_authentication ;;
      4) check_open_ports ;;
      5) check_anonymous_access ;;
      6) check_ssl ;;
      7) send_email ;;
      8) echo "Exiting..."; exit 0 ;;
      *) echo "Invalid choice! Please select again." ;;
    esac
  done
}

# ... (rest of the functions, modified as shown below)

check_mongo_running() {
  echo "Checking MongoDB Status..."
  if systemctl is-active mongod &> /dev/null; then  # More reliable check
    status_check "MongoDB is running." "OK"
  else
    status_check "MongoDB is NOT running!" "WARNING"
  fi
}


check_authentication() {
  echo "Checking Authentication..."
  if grep -q "authorization: enabled" "$MONGO_CONF"; then
    status_check "Authentication is enabled." "OK"
  else
    status_check "Authentication is NOT enabled! Risk: Unauthorized access possible." "WARNING"
  fi
}

check_open_ports() {
  echo "Checking Network Exposure..."
  # Check for binding to all interfaces (0.0.0.0) - HIGH RISK
  if netstat -tulnp | grep ":27017" | grep "0.0.0.0"; then
    status_check "MongoDB is listening on all interfaces (0.0.0.0)! HIGH RISK." "WARNING"
  elif netstat -tulnp | grep ":27017"; then
    status_check "MongoDB is listening on a specific interface." "OK" # Still review the interface!
  else
    status_check "MongoDB is NOT listening on port 27017." "OK" # Could be listening on another port, investigate!
  fi
}

check_anonymous_access() {
    echo "Checking for Anonymous Access..."
    # More robust check using mongo command and JSON output
    if mongo --quiet --eval "db.adminCommand('listDatabases')" | grep -q "errmsg"; then # Check for errors
        status_check "Anonymous access is restricted (or requires authentication)." "OK"
    else
        status_check "Anonymous access is ALLOWED! Risk: Unauthorized access possible." "WARNING"
    fi
}


check_ssl() {
  echo "Checking TLS/SSL Configuration..."
  if grep -q "ssl:" "$MONGO_CONF"; then
    status_check "TLS/SSL is enabled." "OK"
    # Add checks for certificate validity, etc. (More advanced)
  else
    status_check "TLS/SSL is NOT enabled! Risk: Data may be transmitted unencrypted." "WARNING"
  fi
}


run_full_audit() {
  # ... (same as before)
}

interactive_menu

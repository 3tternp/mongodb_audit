#!/bin/bash

# MongoDB Audit Tool
# Author: [Your Name]
# Description: This script audits a MongoDB instance for security and configuration issues.

MONGO_CONF="/etc/mongod.conf"
MONGO_LOG="/var/log/mongodb/mongod.log"
OUTPUT_FILE="mongodb_audit_report.txt"

# Check if MongoDB is running
echo "Checking if MongoDB is running..."
if pgrep mongod > /dev/null; then
    echo "[✔] MongoDB is running."
else
    echo "[✘] MongoDB is NOT running!"
    echo "Please start MongoDB before running the audit."
    exit 1
fi

# Get MongoDB Version
MONGO_VERSION=$(mongo --quiet --eval "db.version()")
echo "[✔] MongoDB Version: $MONGO_VERSION"

# Check if authentication is enabled
AUTH_ENABLED=$(grep "authorization: enabled" $MONGO_CONF)
if [[ -n "$AUTH_ENABLED" ]]; then
    echo "[✔] Authentication is enabled."
else
    echo "[✘] Authentication is NOT enabled! Risk: Unauthorized access possible."
fi

# Check if MongoDB is binding to all IP addresses (Security Risk)
BIND_IP=$(grep "bindIp:" $MONGO_CONF | awk '{print $2}')
if [[ "$BIND_IP" == "0.0.0.0" ]]; then
    echo "[✘] MongoDB is bound to all IPs (0.0.0.0)! Risk: Open to external attacks."
else
    echo "[✔] MongoDB is bound to specific IP: $BIND_IP"
fi

# Check open MongoDB port (Default: 27017)
PORT_STATUS=$(netstat -tulnp | grep "27017")
if [[ -n "$PORT_STATUS" ]]; then
    echo "[✔] MongoDB is running on port 27017."
else
    echo "[✘] MongoDB port 27017 is not open! Risk: Database may not be accessible."
fi

# Check MongoDB Users & Roles
echo "Checking MongoDB users and roles..."
mongo --quiet --eval 'db.runCommand({usersInfo: 1})' > mongo_users.txt
if grep -q '"users"' mongo_users.txt; then
    echo "[✔] Users and roles found."
else
    echo "[✘] No users found! Risk: MongoDB might be running without authentication."
fi
rm -f mongo_users.txt

# Check MongoDB Log File
if [[ -f "$MONGO_LOG" ]]; then
    echo "[✔] MongoDB log file exists: $MONGO_LOG"
else
    echo "[✘] MongoDB log file not found! Risk: No logging enabled."
fi

# Check Database Permissions
echo "Checking database permissions..."
mongo --quiet --eval "db.getUsers()" > mongo_permissions.txt
if grep -q 'roles' mongo_permissions.txt; then
    echo "[✔] Database users and roles exist."
else
    echo "[✘] No roles assigned to users! Risk: Misconfigured permissions."
fi
rm -f mongo_permissions.txt

# Save audit results to file
echo "Saving audit report to $OUTPUT_FILE..."
{
    echo "MongoDB Audit Report - $(date)"
    echo "--------------------------------"
    echo "MongoDB Version: $MONGO_VERSION"
    echo "Authentication Enabled: $( [[ -n "$AUTH_ENABLED" ]] && echo "Yes" || echo "No" )"
    echo "Bind IP: $BIND_IP"
    echo "Port 27017 Open: $( [[ -n "$PORT_STATUS" ]] && echo "Yes" || echo "No" )"
    echo "Users Exist: $( [[ -s mongo_users.txt ]] && echo "Yes" || echo "No" )"
    echo "Log File Exists: $( [[ -f "$MONGO_LOG" ]] && echo "Yes" || echo "No" )"
    echo "Permissions Configured: $( [[ -s mongo_permissions.txt ]] && echo "Yes" || echo "No" )"
} > "$OUTPUT_FILE"

echo "Audit completed. Report saved to $OUTPUT_FILE."

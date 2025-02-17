#!/bin/bash

# MongoDB Configuration File
MONGO_CONF="/etc/mongod.conf"
OUTPUT_FILE="mongodb_cis_audit.txt"

# Function to check if MongoDB is installed
check_mongo_installed() {
    echo "🔹 Checking if MongoDB is installed..." | tee -a "$OUTPUT_FILE"
    if ! command -v mongo &> /dev/null; then
        echo "❌ MongoDB is NOT installed!" | tee -a "$OUTPUT_FILE"
        exit 1
    else
        echo "✅ MongoDB is installed." | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check MongoDB version
check_mongo_version() {
    echo "🔹 Checking MongoDB Version..." | tee -a "$OUTPUT_FILE"
    mongo --version
    echo "✅ Installed MongoDB version: $installed_version" | tee -a "$OUTPUT_FILE"
}

# Function to check authentication configuration
check_authentication() {
    echo "🔹 Checking if authentication is enabled..." | tee -a "$OUTPUT_FILE"
    if grep -q "authorization: enabled" "$MONGO_CONF"; then
        echo "✅ Authentication is enabled." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ Authentication is NOT enabled!" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check if MongoDB bypasses authentication
check_localhost_bypass() {
    echo "🔹 Checking localhost authentication bypass..." | tee -a "$OUTPUT_FILE"
    if grep -q "enableLocalhostAuthBypass: false" "$MONGO_CONF"; then
        echo "✅ Localhost authentication bypass is disabled." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ Localhost authentication bypass is ENABLED!" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check MongoDB running user
check_mongo_user() {
    echo "🔹 Checking if MongoDB is running under a non-root user..." | tee -a "$OUTPUT_FILE"
    if pgrep -u mongodb mongod > /dev/null; then
        echo "✅ MongoDB is running as a non-root user." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ MongoDB is running as root! Please use a dedicated service account." | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check weak TLS protocols
check_weak_tls() {
    echo "🔹 Checking for weak TLS protocols..." | tee -a "$OUTPUT_FILE"
    if grep -q "disabledProtocols: TLS1_0,TLS1_1" "$MONGO_CONF"; then
        echo "✅ Weak TLS protocols are disabled." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ Weak TLS protocols are ENABLED!" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check TLS encryption
check_tls_encryption() {
    echo "🔹 Checking if TLS/SSL is enabled..." | tee -a "$OUTPUT_FILE"
    if grep -q "mode: requireTLS" "$MONGO_CONF"; then
        echo "✅ TLS encryption is enabled." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ TLS encryption is NOT enabled!" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check encryption at rest
check_encryption_at_rest() {
    echo "🔹 Checking encryption at rest..." | tee -a "$OUTPUT_FILE"
    if grep -q "enableEncryption: true" "$MONGO_CONF"; then
        echo "✅ Data encryption at rest is enabled." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ Data encryption at rest is NOT enabled!" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check audit logging
check_audit_logging() {
    echo "🔹 Checking if audit logging is enabled..." | tee -a "$OUTPUT_FILE"
    if grep -q "auditLog:" "$MONGO_CONF"; then
        echo "✅ Audit logging is enabled." | tee -a "$OUTPUT_FILE"
    else
        echo "❌ Audit logging is NOT enabled!" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check if MongoDB is using a non-default port
check_mongo_port() {
    echo "🔹 Checking if MongoDB is using a non-default port..." | tee -a "$OUTPUT_FILE"
    if grep -q "port: 27017" "$MONGO_CONF"; then
        echo "❌ MongoDB is using the DEFAULT port (27017)! Change it for security." | tee -a "$OUTPUT_FILE"
    else
        echo "✅ MongoDB is using a custom port." | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check file permissions
check_file_permissions() {
    echo "🔹 Checking key file permissions..." | tee -a "$OUTPUT_FILE"
    grep -E "keyFile|PEMKeyFile|CAFile" "$MONGO_CONF" | tee -a "$OUTPUT_FILE"
}

# Function to run all checks
run_full_audit() {
    echo "===================================" | tee "$OUTPUT_FILE"
    echo " MongoDB CIS Benchmark Audit Report " | tee -a "$OUTPUT_FILE"
    echo " Generated on: $(date) " | tee -a "$OUTPUT_FILE"
    echo "===================================" | tee -a "$OUTPUT_FILE"

    check_mongo_installed
    check_mongo_version
    check_authentication
    check_localhost_bypass
    check_mongo_user
    check_weak_tls
    check_tls_encryption
    check_encryption_at_rest
    check_audit_logging
    check_mongo_port
    check_file_permissions

    echo "===================================" | tee -a "$OUTPUT_FILE"
    echo " ✅ Audit Completed. Check $OUTPUT_FILE for full details. " | tee -a "$OUTPUT_FILE"
    echo "===================================" | tee -a "$OUTPUT_FILE"
}

# Run the full audit
run_full_audit

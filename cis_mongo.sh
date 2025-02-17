#!/bin/bash

# MongoDB Configuration File
MONGO_CONF="/etc/mongod.conf"
OUTPUT_FILE="mongodb_cis_audit.txt"

# Function to check if MongoDB is installed
check_mongo_installed() {
    if ! command -v mongo &> /dev/null; then
        echo "❌ MongoDB is not installed on this system."
        exit 1
    fi
}

# Function to check MongoDB version
check_mongo_version() {
    echo "🔹 Checking MongoDB Version..."
    installed_version=$(mongo --quiet --eval "db.version()")
    echo "✅ Installed MongoDB version: $installed_version"
}

# Function to check authentication configuration
check_authentication() {
    echo "🔹 Checking if authentication is enabled..."
    grep -q "authorization: enabled" "$MONGO_CONF" && echo "✅ Authentication is enabled." || echo "❌ Authentication is NOT enabled!"
}

# Function to check if MongoDB bypasses authentication
check_localhost_bypass() {
    echo "🔹 Checking localhost authentication bypass..."
    grep -q "enableLocalhostAuthBypass: false" "$MONGO_CONF" && echo "✅ Localhost authentication bypass is disabled." || echo "❌ Localhost authentication bypass is ENABLED!"
}

# Function to check sharded cluster authentication
check_sharded_cluster_auth() {
    echo "🔹 Checking sharded cluster authentication..."
    grep -E "PEMKeyFile|CAFile|clusterFile|clusterAuthMode|authenticationMechanisms:" "$MONGO_CONF" && echo "✅ Authentication for sharded cluster is enabled." || echo "❌ Authentication for sharded cluster is NOT configured properly!"
}

# Function to check RBAC
check_rbac() {
    echo "🔹 Checking Role-Based Access Control..."
    mongo --quiet --eval "db.getUser()" | grep -q "roles" && echo "✅ RBAC is configured." || echo "❌ RBAC is NOT properly configured!"
}

# Function to check MongoDB running user
check_mongo_user() {
    echo "🔹 Checking if MongoDB is running under a non-root user..."
    pgrep -u mongodb mongod > /dev/null && echo "✅ MongoDB is running as a non-root user." || echo "❌ MongoDB is running as root! Please use a dedicated service account."
}

# Function to check weak TLS protocols
check_weak_tls() {
    echo "🔹 Checking for weak TLS protocols..."
    grep -q "disabledProtocols: TLS1_0,TLS1_1" "$MONGO_CONF" && echo "✅ Weak TLS protocols are disabled." || echo "❌ Weak TLS protocols are ENABLED!"
}

# Function to check transport encryption
check_tls_encryption() {
    echo "🔹 Checking if TLS/SSL is enabled..."
    grep -q "mode: requireTLS" "$MONGO_CONF" && echo "✅ TLS encryption is enabled." || echo "❌ TLS encryption is NOT enabled!"
}

# Function to check FIPS mode
check_fips_mode() {
    echo "🔹 Checking if FIPS mode is enabled..."
    grep -q "fipsMode: true" "$MONGO_CONF" && echo "✅ FIPS mode is enabled." || echo "❌ FIPS mode is NOT enabled!"
}

# Function to check encryption at rest
check_encryption_at_rest() {
    echo "🔹 Checking encryption at rest..."
    grep -q "enableEncryption: true" "$MONGO_CONF" && echo "✅ Data encryption at rest is enabled." || echo "❌ Data encryption at rest is NOT enabled!"
}

# Function to check if audit logging is enabled
check_audit_logging() {
    echo "🔹 Checking if audit logging is enabled..."
    grep -q "auditLog:" "$MONGO_CONF" && echo "✅ Audit logging is enabled." || echo "❌ Audit logging is NOT enabled!"
}

# Function to check logging configuration
check_logging_config() {
    echo "🔹 Checking if detailed logging is enabled..."
    grep -q "quiet: false" "$MONGO_CONF" && echo "✅ Detailed logging is enabled." || echo "❌ Detailed logging is NOT enabled!"
}

# Function to check log file append mode
check_log_append() {
    echo "🔹 Checking if log file append mode is enabled..."
    grep -q "logAppend: true" "$MONGO_CONF" && echo "✅ Log append is enabled." || echo "❌ Log append is NOT enabled!"
}

# Function to check if MongoDB is using a non-default port
check_mongo_port() {
    echo "🔹 Checking if MongoDB is using a non-default port..."
    grep -q "port: 27017" "$MONGO_CONF" && echo "❌ MongoDB is using the DEFAULT port (27017)! Change it for security." || echo "✅ MongoDB is using a custom port."
}

# Function to check system resource limits
check_resource_limits() {
    echo "🔹 Checking MongoDB process resource limits..."
    mongo_pid=$(pgrep mongod)
    if [[ -n "$mongo_pid" ]]; then
        cat /proc/$mongo_pid/limits
    else
        echo "❌ MongoDB process not found!"
    fi
}

# Function to check if server-side JavaScript is enabled
check_js_execution() {
    echo "🔹 Checking if server-side JavaScript execution is disabled..."
    grep -q "javascriptEnabled: false" "$MONGO_CONF" && echo "✅ Server-side JavaScript execution is disabled." || echo "❌ Server-side JavaScript execution is ENABLED!"
}

# Function to check file permissions
check_file_permissions() {
    echo "🔹 Checking key file permissions..."
    grep -E "keyFile|PEMKeyFile|CAFile" "$MONGO_CONF"
    ls -l $(grep -Eo "/.*pem" "$MONGO_CONF") 2>/dev/null
}

# Function to check database file permissions
check_db_file_permissions() {
    echo "🔹 Checking database file permissions..."
    grep -q "dbPath" "$MONGO_CONF" && echo "✅ Database path is configured." || echo "❌ Database path is NOT configured!"
}

# Function to run all checks
run_full_audit() {
    echo "===================================" > "$OUTPUT_FILE"
    echo " MongoDB CIS Benchmark Audit Report " >> "$OUTPUT_FILE"
    echo " Generated on: $(date) " >> "$OUTPUT_FILE"
    echo "===================================" >> "$OUTPUT_FILE"

    check_mongo_installed
    check_mongo_version
    check_authentication
    check_localhost_bypass
    check_sharded_cluster_auth
    check_rbac
    check_mongo_user
    check_weak_tls
    check_tls_encryption
    check_fips_mode
    check_encryption_at_rest
    check_audit_logging
    check_logging_config
    check_log_append
    check_mongo_port
    check_resource_limits
    check_js_execution
    check_file_permissions
    check_db_file_permissions

    echo "===================================" >> "$OUTPUT_FILE"
    echo " Audit Completed. Check $OUTPUT_FILE for full details. " >> "$OUTPUT_FILE"
    echo "===================================" >> "$OUTPUT_FILE"

    echo "✅ Audit completed. Report saved to $OUTPUT_FILE."
}

# Run the full audit
run_full_audit

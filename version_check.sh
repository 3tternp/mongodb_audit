#!/bin/bash

# Function to get the installed MongoDB version
get_installed_version() {
    installed_version=$(mongod --version | grep -oP '(?<=db version v)[0-9]+\.[0-9]+\.[0-9]+')
    echo "$installed_version"
}

# Function to get the latest MongoDB version
get_latest_version() {
    latest_version=$(curl -s https://www.mongodb.com/try/download/community | grep -oP '(?<=MongoDB Community Server )[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    echo "$latest_version"
}

# Function to compare versions
compare_versions() {
    if [[ "$1" == "$2" ]]; then
        echo "[✔] You are using the latest MongoDB version: $1"
    else
        echo "[✘] Your MongoDB version ($1) is outdated. Latest version available: $2"
        echo "➡️  Recommended action: Upgrade MongoDB to version $2"
    fi
}

# Check if MongoDB is installed
if ! command -v mongod &> /dev/null; then
    echo "[✘] MongoDB is not installed on this system!"
    exit 1
fi

echo "Checking MongoDB versions..."

installed_version=$(get_installed_version)
latest_version=$(get_latest_version)

if [[ -z "$installed_version" || -z "$latest_version" ]]; then
    echo "[✘] Unable to fetch MongoDB version information."
    exit 1
fi

echo "Installed MongoDB version: $installed_version"
echo "Latest MongoDB version: $latest_version"

compare_versions "$installed_version" "$latest_version"

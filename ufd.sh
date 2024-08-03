#!/bin/sh

# ==============================================
# Universal File Downloader for Android and Linux
# Version: 2.1
# Description: This script downloads user-specified files from a Python http.server
# Author: [Infamousmick]
# Date: [Aug-03-2024]
# ==============================================

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to get IP on Linux
get_ip_linux() {
    ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
    if [ -z "$ip" ]; then
        ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
    fi
    echo "$ip"
}

# Function to get IP on Android
get_ip_android() {
    ip=""
    for interface in wlan0 eth0 rmnet0; do
        temp_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
        if [ ! -z "$temp_ip" ]; then
            ip=$temp_ip
            break
        fi
    done
    if [ -z "$ip" ]; then
        ip=$(getprop dhcp.wlan0.ipaddress)
    fi
    echo "$ip"
}

# Function to verify directory
verify_directory() {
    if command -v curl >/dev/null 2>&1; then
        if curl -s -f "http://$SERVER:$PORT/$1" >/dev/null; then
            return 0
        else
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --spider "http://$SERVER:$PORT/$1"; then
            return 0
        else
            return 1
        fi
    else
        printf "\n${RED}Error: Neither curl nor wget is available.${NC}"
        exit 1
    fi
}

# Print header
printf "\n============================================="
printf "\n   Universal File Downloader for Android/Linux"
printf "\n=============================================\n"

# Ask the user if this is the device that started the hosting
printf "\n${YELLOW}Is this the device that started hosting with http.server? (y/n)${NC}: "
read SAME_DEVICE

if [ "$SAME_DEVICE" = "y" ] || [ "$SAME_DEVICE" = "Y" ]; then
    # Ask if it's Android or Linux
    printf "\n${YELLOW}Is this device Android or Linux? (a/l)${NC}: "
    read DEVICE_TYPE

    if [ "$DEVICE_TYPE" = "a" ] || [ "$DEVICE_TYPE" = "A" ]; then
        SERVER=$(get_ip_android)
        if [ -z "$SERVER" ]; then
            printf "\n${RED}Failed to automatically detect Android IP.${NC}"
            printf "\n${YELLOW}Please enter the IP address manually:${NC} "
            read SERVER
        fi
    else
        SERVER=$(get_ip_linux)
    fi
else
    # Ask for the IP of the device that started hosting
    printf "\n${YELLOW}Enter the IP of the device that started hosting:${NC} "
    read SERVER
fi

# Ask for the port number
printf "\n${YELLOW}Enter the port number (default is 8000):${NC} "
read PORT
if [ -z "$PORT" ]; then
    PORT="8000"
fi

# Ask the user for the file directory and verify it
while true; do
    printf "\n${YELLOW}Enter the path of the directory containing the files \n(press Enter to use the root directory):${NC} "
    read FILE_DIR

    if [ -z "$FILE_DIR" ]; then
        FILE_DIR=""
        break
    elif verify_directory "$FILE_DIR"; then
        break
    else
        printf "\n${RED}Invalid directory. The specified path is not accessible.${NC}"
    fi
done

# Function to download a file
download_file() {
    printf "\n${BLUE}Downloading $1...${NC}"
    if command -v curl >/dev/null 2>&1; then
        if curl -s -f "http://$SERVER:$PORT/$FILE_DIR/$1" -o "$1"; then
            printf "\n${GREEN}$1 downloaded successfully.${NC}"
            return 0
        else
            printf "\n${RED}Failed to download $1. URL: http://$SERVER:$PORT/$FILE_DIR/$1${NC}"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "http://$SERVER:$PORT/$FILE_DIR/$1" -O "$1"; then
            printf "\n${GREEN}$1 downloaded successfully.${NC}"
            return 0
        else
            printf "\n${RED}Failed to download $1. URL: http://$SERVER:$PORT/$FILE_DIR/$1${NC}"
            return 1
        fi
    else
        printf "\n${RED}Error: Neither curl nor wget is available.${NC}"
        exit 1
    fi
}

# Print the IP address and directory
printf "\n${BLUE}Using IP address: $SERVER${NC}"
printf "\n${BLUE}Using port: $PORT${NC}"
printf "\n${BLUE}Using directory: $FILE_DIR${NC}"

# Download files
printf "\n\n${YELLOW}Starting downloads...${NC}"
download_count=0
total_files=0

while true; do
    printf "\n${YELLOW}Enter the name of the file to download (or press Enter to finish):${NC} "
    read filename
    if [ -z "$filename" ]; then
        break
    fi
    total_files=$((total_files + 1))
    download_file "$filename" && download_count=$((download_count + 1))
    
    printf "\n${YELLOW}Do you want to download another file? (y/n):${NC} "
    read another_file
    if [ "$another_file" != "y" ] && [ "$another_file" != "Y" ]; then
        break
    fi
done

# Check if all files were downloaded successfully
if [ $download_count -eq $total_files ]; then
    printf "\n\n${GREEN}All downloads completed successfully.${NC}\n"
else
    printf "\n\n${YELLOW}Download process completed.${NC}\n"
fi

printf "\n============================================\n"
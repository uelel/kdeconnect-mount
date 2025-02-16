#!/bin/bash

ANDROID_USER="kdeconnect"
ANDROID_HOST="" # Fill in host IP address: mount | grep kdeconnect
ANDROID_PORT="" # Fill in port: nmap -p- $ANDOID_HOST
ANDROID_DIR="/storage/emulated/0"
SSH_KEY="$HOME/.config/kdeconnect/privateKey.pem"

# Function to show usage
usage() {
  echo "Usage: $0 (-d <device_id> | -n <device_name>) <mount_path>"
  exit 1
}

# Check if required utilities are installed
for cmd in kdeconnect-cli sshfs qdbus; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required utility '$cmd' is not installed or not available in PATH."
    exit 1
  fi
done

# Parse command-line arguments
DEVICE_ID=""
DEVICE_NAME=""
MOUNT_PATH=""
if [[ "$#" -lt 2 ]]; then
  usage
fi
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -d|--device)
      DEVICE_ID="$2"
      shift 2
      ;;
    -n|--name)
      DEVICE_NAME="$2"
      shift 2
      ;;
    *)
      if [ -z "$MOUNT_PATH" ]; then
        MOUNT_PATH="$1"
        shift
      else
        usage
      fi
      ;;
  esac
done

# Ensure either device ID or device name is provided
# Ensure mount path is provided
if [ -z "$DEVICE_ID" ] && [ -z "$DEVICE_NAME" ]; then
  echo "Error: Either -d <device_id> or -n <device_name> must be provided."
  usage
fi
if [ -z "$MOUNT_PATH" ]; then
  echo "Error: Mount path is required."
  usage
fi

# Resolve device ID from device name
if [ -n "$DEVICE_NAME" ]; then
  echo "Looking up device ID for device name: $DEVICE_NAME..."
  
  DEVICE_LIST=$(kdeconnect-cli -l)
  echo "$DEVICE_LIST"
  
  DEVICE_ID=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^- ]]; then
      # Extract device name and ID using regex
      if [[ "$line" =~ -[[:space:]](.+):[[:space:]]([a-z0-9_]+)[[:space:]]\(.*\) ]]; then
        extracted_name="${BASH_REMATCH[1]}"
        extracted_id="${BASH_REMATCH[2]}"
        if [[ "$extracted_name" == "$DEVICE_NAME" ]]; then
          DEVICE_ID="$extracted_id"
          break
        fi
      fi
    fi
  done <<< "$DEVICE_LIST"

  if [ -z "$DEVICE_ID" ]; then
    echo "Error: No ID found for device name '$DEVICE_NAME'. Ensure the device is paired and reachable."
    exit 1
  fi

  echo "Resolved device name '$DEVICE_NAME' to ID: $DEVICE_ID"
fi


# Check if qdbus is available
if ! command -v qdbus &> /dev/null; then
  echo "Error: qdbus is not installed or not available in PATH."
  exit 1
fi
# Check if kdeconnect service is available
if ! qdbus org.kde.kdeconnect &> /dev/null; then
  echo "Error: kdeconnect service is not running or not available."
  exit 1
fi

# Activate SFTP service for the given device ID
echo "Activating SFTP service for device ID: $DEVICE_ID"
qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$DEVICE_ID/sftp" org.kde.kdeconnect.device.sftp.mount
if [ $? -ne 0 ]; then
  echo "Error: Failed to activate SFTP service for device $DEVICE_ID."
  exit 1
fi

echo "Mounting the Android device at $MOUNT_PATH"
sshfs -o rw,nosuid,nodev,identityfile="$SSH_KEY",port="$ANDROID_PORT",uid=$(id -u),gid=$(id -g),allow_other "$ANDROID_USER@$ANDROID_HOST:$ANDROID_DIR" "$MOUNT_PATH"

# Check if the mount was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to mount the Android filesystem."
  exit 1
fi

echo "Android device mounted successfully at $MOUNT_PATH."

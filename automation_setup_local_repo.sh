#!/bin/bash

# Define variables
SERVER_IP="<server_ip>"
ISO_PATH="/path/to/your/rhel-8.10-86_64-dvd.iso"
REMOTE_ISO_PATH="/var/www/html/rhel8/rhel-8.10-86_64-dvd.iso"
MOUNT_POINT="/mnt/rhel8"
REPO_BASE="/var/www/html/repos/rhel8"

# Connect to the server via SSH and perform operations
ssh cloud@$SERVER_IP << EOF

# Switch to the root user
sudo su - << EOSU

# Create the directory for the ISO
mkdir -p /var/www/html/rhel8

# Set directory permissions
chmod 755 /var/www/html/rhel8

# Exit root user session
exit
EOSU

# Transfer the ISO file to the server
scp $ISO_PATH cloud@$SERVER_IP:/var/www/html/rhel8/

# Reconnect to the server via SSH
ssh cloud@$SERVER_IP << EOF

# Verify the directory and file
ls /var/www/html/rhel8

# Create the mount point
mkdir -p $MOUNT_POINT

# Mount the ISO
mount -o loop /var/www/html/rhel8/rhel-8.10-86_64-dvd.iso $MOUNT_POINT

# Verify the mount
df -h
ls $MOUNT_POINT

# Create local repository directories
sudo mkdir -p $REPO_BASE/BaseOS
sudo mkdir -p $REPO_BASE/Appstream

# Copy packages to the repository
sudo cp -r $MOUNT_POINT/BaseOS/* $REPO_BASE/BaseOS/
sudo cp -r $MOUNT_POINT/Appstream/* $REPO_BASE/Appstream/

# Install createrepo if needed
if ! rpm -q createrepo >/dev/null 2>&1; then
    sudo yum install -y createrepo
fi

# Create repository metadata
cd $REPO_BASE
sudo createrepo BaseOS
sudo createrepo Appstream

# Unmount the ISO
sudo umount $MOUNT_POINT

EOF
EOF


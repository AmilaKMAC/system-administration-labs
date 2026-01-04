#!/bin/bash

# Automate Disk partitioning, Formatting, and Mounting

# Check if running as root
if [ "$EUID" -ne 0 ]; then  # EUID == 0 == Root
	echo "Please Run as Root"
	exit 1 
fi


echo "=== Disk Setup Automation ==="
echo ""

# Variables
DISK="/dev/sdb"
PARTITION="${DISK}1"
MOUNT_POINT="/data"
FS_TYPE="ext4"


# Check if Disk is Exists
if [ ! -b "$DISK" ]; then
	echo "Disk $DISK not Found!"
	echo "Please add a new disk in Virtual Machine First"
	exit 1
fi



echo "Found Disk: $DISK"
echo ""



# Show Current Disk Status
echo "----- Current Disk Status -----"
lsblk $DISK
echo ""


# Warning
read -p "This will DELETE ALL DATA on $DISK. continue? (yes/no)" confirm
if [ "$confirm" != "yes" ]; then
	echo "Aborted."
	exit 0
fi


echo ""
echo "--- step 1: Creating Partition ---"

# Creating Partition using fdisk
(
echo n # New Partition
echo p # Primary
echo 1 # Partition Number
echo # Default First Number
echo # Default Last Number
echo w # Write Changes
) | fdisk $DISK

# Inform kernel of partition changes
partprobe $DISK
sleep 2

if [ ! -b "$PARTITION" ]; then
	echo "Failed to Create Partition"
	exit 1
fi

echo "Partition Created: $PARTITION"
echo ""


# Format Partition
echo "--- step 2: Formatting Partition ---"
mkfs.$FS_TYPE $PARTITION

if [ $? -ne 0 ]; then
	echo "Failed to Format Partition"
	exit 1
fi

echo "Formated as $FS_TYPE"
echo ""


# Get UUID
UUID=$(blkid -s UUID -o value $PARTITION)
echo "UUID: $UUID"
echo ""


# Create Mount Point
echo "--- step 3: Creating Mount Point ---"
mkdir -p $MOUNT_POINT

if [ $? -ne 0 ]; then
	echo "Failed to Mount Partition"
	exit 1
fi


echo "Mounted $PARTITION to $MOUNT_POINT"
echo ""



# Mount Partition
echo "--- step 4: Mounting Partition ---"
mount $PARTITION $MOUNT_POINT

if [ $? -ne 0 ]; then
	echo "Failed Mount Partition"
	exit 1
fi

echo "Mounted $PARTITION to $MOUNT_POINT"
echo ""


# Create Test File
echo "--- step 5: Testing Mount ---"
echo "This is a Test File Created by disk_setup.sh" > $MOUNT_POINT/test-file.txt
chown $SUDO_USER:$SUDO_USER $MOUNT_POINT/test-file.txt 2>/dev/null


if [ -f "$MOUNT_POINT/test-file.txt" ]; then
	echo "Test File Created Successfully"
else
	echo "Could not Created the File"
fi
echo ""



# Configure fstab for persistent mount
echo "--- step 6: Configuring Persistent Mount"

# Backup fstab
cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)  # Created Backup File
echo "Backed up /etc/fstab"


# Check if entry already exist
if grep -q "$UUID" /etc/fstab; then
	echo "Entry already exists in /etc/fstab"
else
	# Add entry to fstab
	echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab
	echo "Added Entry /etc/fstab"
fi


# Test fstab
echo ""
echo "--- step 7: Testing fstab ---"
umount $MOUNT_POINT
mount -a

if mountpoint -q $MOUNT_POINT; then
	echo "fstab Configuration Successful"
else
	echo "fstab Test Failed"
	exit 1
fi


echo ""
echo "=== Setup Completed ==="
echo ""
echo "Summary"
echo " Disk: $DISK"
echo " Partition: $PARTITION"
echo " Filesystem: $FS_TYPE"
echo "Mount Point: $MOUNT_POINT"
echo "UUID: $UUID"
echo ""
df -h | grep $MOUNT_POINT
lsblk $DISK
echo ""
echo "This Disk will Automatically Mount on Reboot"

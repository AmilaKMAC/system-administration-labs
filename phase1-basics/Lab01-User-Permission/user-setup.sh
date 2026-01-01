#!/bin/bash

echo "=== USER AND GROUP SETUP INITIATED ==="
# Create users and groups

echo "[INFO] Creating users..."
sudo useradd -m john
sudo useradd -m sarah

# Set passwords
echo "[INFO] Setting passwords for users..."
sudo passwd john
sudo passwd sarah

# Create a group
echo "[INFO] Creating group: developers..."
sudo groupadd developers

# Add users to group
echo "[INFO] Adding users to developers group..."
sudo usermod -aG developers john
sudo usermod -aG developers sarah

# Practice permissions
echo "[INFO] Creating shared directory..."
sudo mkdir /shared

echo "[INFO] Applying ownership and permissions to /shared..."
sudo chown root:developers /shared
sudo chmod 770 /shared

# Create files and test access
echo "[INFO] Creating test file as user john..."
sudo su - john
touch /shared/project.txt
echo "=== SCRIPT EXECUTION COMPLETED SUCCESSFULLY ==="


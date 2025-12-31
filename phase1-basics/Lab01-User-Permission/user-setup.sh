#!/bin/bash

# Create users and groups
sudo useradd -m john
sudo useradd -m sarah
sudo groupadd developers
sudo usermod -aG developers john

# Practice permissions
mkdir /shared
sudo chown root:developers /shared
sudo chmod 770 /shared

# Create files and test access
sudo su - john
touch /shared/project.txt

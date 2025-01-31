#!/bin/bash

echo "Installing required dependencies..."

# Gerekli paketleri yükle
sudo apt update
sudo apt install -y smbclient

# Script'i /usr/local/bin/ altına kopyala
sudo cp ./smbscanner.sh /usr/local/bin/smbscanner
sudo chmod +x /usr/local/bin/smbscanner

echo "smbscanner successfully installed!"
echo "Running smbscanner -h to verify installation..."
echo "------------------------------------------------"
smbscanner -h

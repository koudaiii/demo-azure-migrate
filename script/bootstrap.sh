#!/bin/bash

# Variables
PREFIX=$(date +%Y%m%d%H%M%S)
RESOURCE_GROUP="myResourceGroup$PREFIX"
LOCATION="westus"
VM_NAME=$(echo "myVM$PREFIX" | cut -c 1-15)
# Generate a random password
PASSWORD=$(openssl rand -base64 123 | tr -dc '[:alnum:][:punct:]' | tr -d '\n' | head -c 123)

# az login
az login

# Create a resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a new virtual network
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name myVnet \
  --address-prefixes 192.168.0.0/16 \
  --subnet-name mySubnet \
  --subnet-prefixes 192.168.20.0/24

# Create an azure migrate appliance on virtual machine
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Win2022Datacenter \
  --admin-username azureuser \
  --admin-password $PASSWORD \
  --vnet-name myVnet \
  --subnet mySubnet \
  --size Standard_DS3_v2 \
  --generate-ssh-keys

# Create an app on virtual machine
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name app \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --vnet-name myVnet \
  --subnet mySubnet \
  --generate-ssh-keys \
  --custom-data "#cloud-config
apt_update: true
apt_upgrade: true
packages:
  - zlib1g
  - dotnet-sdk-8.0
  - aspnetcore-runtime-8.0
  - dotnet-runtime-8.0
  - nginx
runcmd:
  - git clone https://github.com/koudaiii/demo-azure-migrate.git
  - cd demo-azure-migrate
  - dotnet publish -c Release -o /var/www/html
  - cp etc/nginx/sites-available/default /etc/nginx/sites-available/default
  - cp etc/systemd/system/app.service /etc/systemd/system/app.service
  - systemctl enable app
  - systemctl start app
  - systemctl restart nginx"

# Get the private IP address of the Windows Server
WIN_IP_ADDRESS=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query privateIps -o tsv)
# Get the private IP address of the Ubuntu Server
Ubuntu2204_IP_ADDRESS=$(az vm show -d -g $RESOURCE_GROUP -n app --query privateIps -o tsv)

echo "--------------------------------------------"
echo "PREFIX: $PREFIX"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "LOCATION: $LOCATION"
echo "VM_NAME: $VM_NAME"
echo "USERNAME: azureuser"
echo "Password: $PASSWORD"
echo "WIN_IP_ADDRESS: $WIN_IP_ADDRESS"
echo "Ubuntu2204_IP_ADDRESS: $Ubuntu2204_IP_ADDRESS"
echo "Install Azure Migrate Appliance ref https://learn.microsoft.com/ja-jp/azure/migrate/tutorial-discover-physical"

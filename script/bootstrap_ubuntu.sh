#!/bin/bash

# Variables
PREFIX=$(date +%Y%m%d%H%M%S)
RESOURCE_GROUP="myResourceGroup$PREFIX"
LOCATION="westus"
VM_NAME="myVM$PREFIX"
GITHUB_USERNAME="koudaiii"
REPO_NAME="demo-azure-migrate"

# Create a resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a new virtual machine
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys

# Get the public IP address of the VM
IP_ADDRESS=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

# SSH into the VM and install .NET Core
ssh azureuser@$IP_ADDRESS << EOF
  wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo apt-get update
  sudo apt-get install -y apt-transport-https
  sudo apt-get update
  sudo apt-get install -y dotnet-sdk-3.1

  # Clone the application from GitHub and run it
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
  cd $REPO_NAME
  dotnet run
EOF

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
  --image Win2019Datacenter \
  --admin-username azureuser \
  --admin-password mySecurePassword \
  --generate-ssh-keys

# Get the public IP address of the VM
IP_ADDRESS=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

# SSH into the VM and install .NET Core
ssh azureuser@$IP_ADDRESS << EOF
  # Download the .NET Core SDK
  Invoke-WebRequest -OutFile dotnet-sdk-installer.exe https://download.visualstudio.microsoft.com/download/pr/5c281f95-91c4-499d-baa2-31fec919047a/48ab32ea92ea3432eaa7e6b3f3d60e3e/dotnet-sdk-3.1.403-win-x64.exe

  # Install the .NET Core SDK
  Start-Process -Wait -FilePath .\dotnet-sdk-installer.exe

  # Clone the application from GitHub and run it
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
  cd $REPO_NAME
  dotnet run
EOF

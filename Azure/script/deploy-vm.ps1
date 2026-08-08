<#
.SYNOPSIS
    Deploys a complete Azure VM environment using PowerShell + Azure CLI.

.DESCRIPTION
    Creates:
    - Resource Group
    - Virtual Network
    - Subnet
    - Network Security Group
    - Public IP
    - Network Interface
    - Virtual Machine
    - Tags

.EXAMPLE
    .\deploy-vm.ps1 -VMName "LabVM01" -Location "eastus"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [Parameter(Mandatory=$true)]
    [string]$Location
)

# Login to Azure
Write-Host "Logging into Azure..." -ForegroundColor Cyan
az login

# Resource Group
$RG = "$VMName-RG"
Write-Host "Creating Resource Group: $RG" -ForegroundColor Yellow
az group create --name $RG --location $Location

# VNET + Subnet
Write-Host "Creating VNET and Subnet..." -ForegroundColor Yellow
az network vnet create `
    --resource-group $RG `
    --name "$VMName-VNET" `
    --address-prefix "10.0.0.0/16" `
    --subnet-name "$VMName-Subnet" `
    --subnet-prefix "10.0.1.0/24"

# NSG
Write-Host "Creating Network Security Group..." -ForegroundColor Yellow
az network nsg create `
    --resource-group $RG `
    --name "$VMName-NSG"

# Allow RDP
az network nsg rule create `
    --resource-group $RG `
    --nsg-name "$VMName-NSG" `
    --name "Allow-RDP" `
    --protocol tcp `
    --priority 1000 `
    --destination-port-range 3389 `
    --access allow

# Public IP
Write-Host "Creating Public IP..." -ForegroundColor Yellow
az network public-ip create `
    --resource-group $RG `
    --name "$VMName-PIP"

# NIC
Write-Host "Creating NIC..." -ForegroundColor Yellow
az network nic create `
    --resource-group $RG `
    --name "$VMName-NIC" `
    --vnet-name "$VMName-VNET" `
    --subnet "$VMName-Subnet" `
    --network-security-group "$VMName-NSG" `
    --public-ip-address "$VMName-PIP"

# VM Deployment
Write-Host "Deploying VM..." -ForegroundColor Yellow
az vm create `
    --resource-group $RG `
    --name $VMName `
    --image "Win2022Datacenter" `
    --admin-username "azureadmin" `
    --admin-password "Password123!" `
    --nics "$VMName-NIC" `
    --size "Standard_B2s" `
    --tags "Environment=Lab" "Owner=Taerence"

Write-Host "`nVM Deployment Complete!" -ForegroundColor Green

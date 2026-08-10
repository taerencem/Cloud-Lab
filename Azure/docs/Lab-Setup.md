# Azure VM Deployment Lab

This lab deploys a complete Azure VM environment using PowerShell and Azure CLI.

## What It Creates

- Resource Group  
- VNET + Subnet  
- Network Security Group  
- Public IP  
- NIC  
- Windows Server 2022 VM  
- Tags  

## Usage

```powershell
.\deploy-vm.ps1 -VMName "LabVM01" -Location "eastus"

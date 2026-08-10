```powershell
<#
.SYNOPSIS
    Creates an Azure Monitor alert rule for VM CPU usage.

.EXAMPLE
    .\azure-monitor-alert.ps1 -RG "MonitorRG" -VMName "LabVM01"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RG,

    [Parameter(Mandatory=$true)]
    [string]$VMName
)

Write-Host "Creating Azure Monitor Alert..." -ForegroundColor Cyan

az monitor metrics alert create `
    --name "CPUAlert-$VMName" `
    --resource-group $RG `
    --scopes "/subscriptions/<SUB-ID>/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/$VMName" `
    --condition "avg Percentage CPU > 80" `
    --description "CPU usage above 80%"

Write-Host "Alert Created!" -ForegroundColor Green

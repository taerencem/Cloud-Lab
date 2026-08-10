<#
.SYNOPSIS
    Checks hybrid Azure AD join status for Windows devices.

.DESCRIPTION
    Retrieves device registration status, join type, and tenant info.
    Useful for troubleshooting hybrid identity and Azure AD Connect.

.EXAMPLE
    .\hybrid-join.ps1
#>

Write-Host "Checking Hybrid Azure AD Join Status..." -ForegroundColor Cyan

$dsreg = dsregcmd /status

# Parse dsregcmd output
$DeviceState = @{
    "AzureAdJoined" = ($dsreg | Select-String "AzureAdJoined").ToString().Split(":")[1].Trim()
    "DomainJoined"  = ($dsreg | Select-String "DomainJoined").ToString().Split(":")[1].Trim()
    "DeviceId"      = ($dsreg | Select-String "DeviceId").ToString().Split(":")[1].Trim()
    "TenantId"      = ($dsreg | Select-String "TenantId").ToString().Split(":")[1].Trim()
    "TenantName"    = ($dsreg | Select-String "TenantName").ToString().Split(":")[1].Trim()
}

$DeviceState | Format-List

# Export JSON
$DeviceState | ConvertTo-Json | Out-File "../examples/hybrid-join-output.json"

Write-Host "`nHybrid Join Status Exported!" -ForegroundColor Green

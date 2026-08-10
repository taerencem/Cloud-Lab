<#
.SYNOPSIS
    Forces Azure AD Connect synchronization.

.DESCRIPTION
    Runs a delta sync or full sync depending on parameter.
    Useful for hybrid identity troubleshooting and onboarding.

.PARAMETER FullSync
    Runs a full sync instead of delta.

.EXAMPLE
    .\force-sync.ps1 -FullSync
#>

param(
    [switch]$FullSync
)

Import-Module ADSync

if ($FullSync) {
    Write-Host "Running FULL Azure AD Connect Sync..." -ForegroundColor Yellow
    Start-ADSyncSyncCycle -PolicyType Initial
} else {
    Write-Host "Running DELTA Azure AD Connect Sync..." -ForegroundColor Yellow
    Start-ADSyncSyncCycle -PolicyType Delta
}

Write-Host "Sync Complete!" -ForegroundColor Green

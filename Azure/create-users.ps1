<#
.SYNOPSIS
    Creates Azure AD users, assigns licenses, and configures roles.

.DESCRIPTION
    Reads a CSV file and provisions cloud-only Azure AD users.
    Assigns Microsoft 365 licenses, adds admin roles, and sets MFA state.

.PARAMETER CSVPath
    Path to the CSV file containing user information.

.EXAMPLE
    .\create-users.ps1 -CSVPath "../examples/azure-users.csv"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CSVPath
)

Import-Module AzureAD

Write-Host "Connecting to Azure AD..." -ForegroundColor Cyan
Connect-AzureAD

$Users = Import-Csv -Path $CSVPath

foreach ($user in $Users) {

    Write-Host "Creating user: $($user.DisplayName)" -ForegroundColor Yellow

    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $user.Password

    $NewUser = New-AzureADUser -DisplayName $user.DisplayName `
        -UserPrincipalName $user.UserPrincipalName `
        -MailNickname $user.MailNickname `
        -AccountEnabled $true `
        -PasswordProfile $PasswordProfile

    Write-Host "User created: $($user.UserPrincipalName)" -ForegroundColor Green

    # Assign License
    if ($user.SkuId -ne "") {
        Write-Host "Assigning license: $($user.SkuId)" -ForegroundColor Yellow
        Set-AzureADUserLicense -ObjectId $NewUser.ObjectId -AssignedLicenses @{Add=$user.SkuId}
    }

    # Assign Role
    if ($user.Role -ne "") {
        Write-Host "Adding role: $($user.Role)" -ForegroundColor Yellow
        $Role = Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq $user.Role}
        Add-AzureADDirectoryRoleMember -ObjectId $Role.ObjectId -RefObjectId $NewUser.ObjectId
    }

    # MFA State
    if ($user.MFA -eq "Enabled") {
        Write-Host "Enforcing MFA..." -ForegroundColor Yellow
        Set-MsolUser -UserPrincipalName $user.UserPrincipalName -StrongAuthenticationRequirements @(
            New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement -Property @{
                RelyingParty = "*"
                State = "Enabled"
            }
        )
    }

    Write-Host "Provisioning complete for: $($user.DisplayName)" -ForegroundColor Cyan
}

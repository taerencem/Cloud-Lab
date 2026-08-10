# Azure AD User Provisioning Script Guide

This script creates Azure AD users, assigns licenses, adds admin roles, and configures MFA.

## Usage

```powershell
.\create-users.ps1 -CSVPath "../examples/azure-users.csv"

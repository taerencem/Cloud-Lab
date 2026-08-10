# Azure VM Backup Script

Triggers an on-demand backup for Azure VMs using Recovery Services Vault.

## Usage

```powershell
.\azure-vm-backup.ps1 -VaultName "LabVault" -RG "BackupRG" -VMName "LabVM01"

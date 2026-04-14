# W5 | S13 | The Automated Onboarding

## Mission
Automate the creation of 50 engineer identities across the TitanCorp Sovereign Domain using PowerShell and Active Directory.

## Environment
| Component | Value |
|-----------|-------|
| Server | Windows Server 2022 Core |
| Domain | titan.local |
| Domain Controller | TITAN-DC01 |
| OU | OU=Engineering,DC=titan,DC=local |

## What Was Done

### Phase 1 — Domain Controller Setup
- Installed Windows Server 2022 (Core, no GUI)
- Configured computer name: `TITAN-DC01`
- Set DNS to `127.0.0.1`
- Installed AD Domain Services role
- Promoted server to Domain Controller with forest `titan.local`

### Phase 2 — Automated Onboarding
- Created Organizational Unit: `Engineering`
- Wrote PowerShell automation script to provision engineer accounts
- Used a `for` loop to generate `Eng_User1` through `Eng_User5`
- Each user was placed in `OU=Engineering,DC=titan,DC=local`
- Each user required a password change at first logon

## The Script

```powershell
# ==================================================
# SESSION 13: THE AUTOMATED ONBOARDING
# Operator Deployment Script
# ==================================================

Write-Host "[*] Beginning Engineering Onboarding..."

for ($i = 1; $i -le 5; $i++) {
    New-ADUser `
        -Name "Eng_User$i" `
        -SamAccountName "Eng_User$i" `
        -Path "OU=Engineering,DC=titan,DC=local" `
        -AccountPassword (ConvertTo-SecureString "YourPassword" -AsPlainText -Force) `
        -ChangePasswordAtLogon $true `
        -Enabled $true
}

Write-Host "[+] All engineers onboarded successfully."
```

## Verification

```powershell
Get-ADUser -Filter 'Name -like "Eng*"' | Select-Object Name, DistinguishedName
```

### Output
```
Name       DistinguishedName
----       -----------------
Eng_User1  CN=Eng_User1,OU=Engineering,DC=titan,DC=local
Eng_User2  CN=Eng_User2,OU=Engineering,DC=titan,DC=local
Eng_User3  CN=Eng_User3,OU=Engineering,DC=titan,DC=local
Eng_User4  CN=Eng_User4,OU=Engineering,DC=titan,DC=local
Eng_User5  CN=Eng_User5,OU=Engineering,DC=titan,DC=local
```

## Key Concepts
- **Active Directory Domain Services (AD DS)** — The directory service managing identities in the domain
- **Organizational Unit (OU)** — A container used to organize users within the domain
- **New-ADUser** — PowerShell cmdlet to create user accounts in Active Directory
- **Distinguished Name (DN)** — The full path of an object in Active Directory
- **ChangePasswordAtLogon** — Security policy forcing users to set their own password on first loginls
# ==================================================
# SESSION 13: THE AUTOMATED ONBOARDING
# Operator Deployment Script
# ==================================================

Write-Host "[*] Beginning Engineering Onboarding..."

# INSTRUCTION 1: Create a loop (For 1 to 5)
for ($i = 1; $i -le 5; $i++) {

# INSTRUCTION 2: Inside the loop, use New-ADUser
    New-ADUser `
        -Name "Eng_User$i" `
        -SamAccountName "Eng_User$i" `
        -Path "OU=Engineering,DC=titan,DC=local" `
        -AccountPassword (ConvertTo-SecureString "@Wend06" -AsPlainText -Force) `
        -ChangePasswordAtLogon $true `
        -Enabled $true
}

Write-Host "[+] All engineers onboarded successfully."
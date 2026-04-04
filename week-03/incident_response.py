#!/usr/bin/env python3
import subprocess
import json

print("[*] Initiating Automated Threat Hunt...")

# TASK 1: Use subprocess to grep for "Failed password" in /var/log/titan_sim/auth_sim.log
# Ensure you capture the output and convert it to text!
# YOUR CODE HERE:

result = subprocess.run(
    ["grep", "Failed password", "/var/log/titan_sim/auth_sim.log"],
    capture_output=True,
    text=True
)

raw_output = result.stdout

# TASK 2: Parse the captured output to extract ONLY the attacking IP addresses.
# Hint: Loop through each line, split the line by spaces, and grab index [10].
# Save the IPs to a Python List called attacker_ips.
# YOUR CODE HERE:

lines = raw_output.split('\n')
attacker_ips = []

for line in lines:
    if line:  
        ip = line.split(" ")[10] 
        attacker_ips.append(ip)


# TASK 3: Create a dictionary containing the extracted IPs and export it to 'threat_report.json'
# Dictionary format: {"alert_type": "Brute Force", "attacker_ips": attacker_ips}
# YOUR CODE HERE:

alert_data = {
    "alert_type": "Brute Force",
    "attacker_ips": attacker_ips
}

with open("threat_report.json", "w") as file:
    json.dump(alert_data, file, indent=4)

print("Threat report generated successfully.")
print(f"Total attacking IPs found: {len(attacker_ips)}")
print("[+] Threat Hunt Complete. Report generated.")

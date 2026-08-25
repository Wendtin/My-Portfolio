
attack_count = 0

with open("auth_audit.log", "r") as log_file:
    with open("brute_report.txt", "w") as report_file:
        for line in log_file:
            if "Failed password" in line:
                report_file.write(line)
                attack_count = attack_count + 1

# This MUST be flush against the left side
print(f"[*] Audit Complete. Extracted {attack_count} threat signatures to brute_report.txt")

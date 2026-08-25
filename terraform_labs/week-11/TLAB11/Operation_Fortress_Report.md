# OPERATION FORTRESS: DEFENSE IN DEPTH REPORT
**Operator:** ## LAYER 1: PERIMETER FIREWALL (iptables)
**Objective:** Block egress to C2 Subnet 198.51.100.0/24
**Rule Used:** iptables -A OUTPUT -d 198.51.100.0/24 -j DROP

## LAYER 2: NETWORK IDS (Suricata)
**Objective:** Detect web shell execution "cmd=whoami"
**Signature Used:** alert tcp any any -> any 80 (msg:"Web Shell Detected - cmd whoami"; content:"cmd=whoami"; sid:1000001; rev:1;)

## LAYER 3: ENDPOINT SECURITY (Sysmon)
**Objective:** Alert on payload download via curl
**XML Condition Used:** <CommandLine condition="contains">curl http://198.51.100.5</CommandLine>

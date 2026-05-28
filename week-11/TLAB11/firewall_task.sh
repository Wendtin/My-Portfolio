#!/bin/bash
# TASK 1: Block outbound traffic to C2 Subnet 198.51.100.0/24
iptables -F
iptables -A OUTPUT -d 198.51.100.0/24 -j DROP


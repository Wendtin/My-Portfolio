import socket

#A list of our server IPs

targets=["127.0.0.1", "8.8.8.8", "1.1.1.1", "10.0.0.1"]

for ip in targets:
    print(f"---Checking Server: {ip}---")

#Create a 'digital hand' to knock on the door

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#Set a timer so we don't wait forever (1 second)

s.settimeout(1)

#knock on port 22 (SSH)

result=s.connect_ex((ip, 22))

# Interpreter the result: 0 means 'Open', anything else means 'Closed'

if result == 0:
    print(f"SUCCESS: Port 22 is OPEN on {ip}")
else:
    print(f"FAILED: Port 22 is CLOSED on {ip}")

#close the connection

s.close()

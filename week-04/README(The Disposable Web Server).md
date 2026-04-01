# W4 | S11 — Disposable Web Server Lab

**Course:** Titan Security Training  
**Session:** 11  
**Topic:** Docker Containers & Ephemeral Infrastructure

---

## Overview

This lab demonstrates how to deploy and destroy a temporary web server using Docker containers. The core security principle is **ephemeral infrastructure** — spin up fast, use it, destroy it completely, leave no footprint for attackers.

---

## Prerequisites

- Kali Linux (or Ubuntu-based system)
- Docker installed and running
- sudo privileges

---

## Phase 1 — Docker 101

Basic container operations using Alpine Linux (5MB minimal distro).

```bash
# Pull the image
docker pull alpine

# Enter the container interactively
docker run -it alpine sh

# Verify process isolation (namespaces at work)
ps aux

# Exit and stop the container
exit
```

**Key concept:** The `ps aux` output inside the container shows only a handful of processes — not the hundreds running on the host. This is Linux **namespaces** enforcing isolation.

---

## Phase 2 — The Disposable Web Server

### 1. Run the Initialization Script

```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/402dd14250b5bc3a7417f6fd7b8e7676/raw/fb4aa7f0ea02f1677a8a91356344dda9af8e0285/deploy_web.sh | sudo bash
```

### 2. Launch the Server

```bash
docker run -d --name training-web -p 8080:80 nginx
```

| Flag | Purpose |
|------|---------|
| `-d` | Detached — runs in the background |
| `--name training-web` | Human-readable container name |
| `-p 8080:80` | Maps host port 8080 → container port 80 |

### 3. Modify the Default Page

```bash
# Enter the running container
docker exec -it training-web bash

# Change the default webpage
echo "Titan Security Training" > /usr/share/nginx/html/index.html

# Exit the container
exit
```

### 4. Audit the Logs

```bash
docker logs training-web
```

### 5. Destroy the Server

```bash
docker stop training-web
docker rm training-web

# Verify it is gone
docker ps -a
```

---

## Automation Script — deploy_web.sh

The artifact script automates deployment:

```bash
#!/bin/bash
# Add your docker run command below this line
docker run -d --name training-web -p 8080:80 nginx
```

### Test the Script

```bash
./deploy_web.sh
```

> If a conflict error appears, remove the existing container first:
> ```bash
> docker rm -f training-web && ./deploy_web.sh
> ```

---

## Submission

```bash
# Submit artifact to command
session-submit --session 11 --artifact ~/deploy_web.sh

# Git flow
git add ~/deploy_web.sh
git commit -m "W4 | S11 | Disposable Web Server deployed"
git push
```

---

## Troubleshooting

### Port Already in Use

```bash
# Check what is holding the port
sudo ss -tlnp | grep 8080

# If host nginx is running, stop it
sudo systemctl stop nginx
```

### Container Name Conflict

```bash
# Remove the conflicting container
docker rm training-web
```

### Container Not Running

```bash
# Check all containers including stopped ones
docker ps -a
```

---

## Security Concepts Covered

- **Linux Namespaces** — process and network isolation between containers and host
- **Ephemeral Infrastructure** — no persistent server means no persistent attack surface
- **Footprint Minimization** — `docker stop` + `docker rm` leaves zero filesystem remnant
- **Rapid Redeployment** — automation script allows identical rebuild in seconds

---

*Titan Security Training — Week 4, Session 11*
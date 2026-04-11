# 🎼 S12: The Conductor and the Fleet
### Docker Compose · Multi-Container Orchestration · Network Isolation

---

## 📌 Project Overview

This project demonstrates deploying a segmented WordPress stack using **Docker Compose**. The architecture enforces network isolation by placing the web server on a public-facing network while air-gapping the database on a fully internal network with no internet access.

This was completed as part of a hands-on DevOps lab focused on container orchestration and secure infrastructure design.

---

## 🏗️ Architecture

```
          [ Internet / Users ]
                  |
           [ frontend network ]
                  |
          [ WordPress Container ]
                  |
           [ backend network ]   ← internal: true (no internet)
                  |
           [ MySQL DB Container ]
```

| Container   | Network(s)          | Internet Access |
|-------------|---------------------|-----------------|
| WordPress   | frontend + backend  | ✅ Yes           |
| MySQL DB    | backend only        | ❌ No (Air-Gapped) |

---

## 🛠️ Technologies Used

- **Docker** — Container runtime
- **Docker Compose** — Multi-container orchestration
- **WordPress** — Web application layer
- **MySQL 5.7** — Database layer
- **Linux (Ubuntu)** — Host environment

---

## 📄 docker-compose.yml

```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress
    ports:
      - "8080:80"
    networks:
      - frontend
      - backend

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: example
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

---

## 🔐 Key Security Concept: `internal: true`

Setting `internal: true` on the `backend` network instructs Docker to create a **network with no external gateway**. This means:

- The database container **cannot initiate or receive connections from the internet**
- It can **only communicate with other containers** on the same internal network
- This mirrors real-world DMZ (Demilitarized Zone) architecture used in production environments

---

## 🧪 Verification Steps

### ✅ WordPress — Internet Access Confirmed
```bash
docker-compose exec wordpress bash
ping -c 2 google.com
# Expected: packets transmitted successfully
exit
```

### ❌ Database — Air-Gap Confirmed
```bash
docker-compose exec db bash
ping -c 2 google.com
# Expected: Network Unreachable
exit
```

---

## 🚀 How to Run

```bash
# Clone the repo
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

# Launch the stack
docker-compose up -d

# Verify running containers
docker-compose ps

# Tear down
docker-compose down
```

---

## 📚 What I Learned

- How to define multi-container environments using a single `docker-compose.yml` file
- How Docker Compose networks work and how to assign containers to specific networks
- How to enforce **network-level isolation** using the `internal: true` flag
- The difference between bridge networks (with internet access) and internal networks (air-gapped)
- How this pattern maps to real-world **DMZ / segmented network architecture**

---

## 📁 Repository Structure

```
.
└── docker-compose.yml   # Main Compose file with air-gapped network configuration
└── README.md            # Project documentation
```

---

*Completed as part of Week 4 · Session 12 of a hands-on DevOps/Cloud curriculum.*
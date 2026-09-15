# Day 72 — Ansible Project: Automate Docker and Nginx Deployment

## 📌 Project Overview

This project demonstrates how to use **Ansible** to automate the deployment and configuration of a Docker-based application on an AWS EC2 instance.

The project uses custom Ansible roles to:

* Configure the Linux server
* Install common packages
* Create a deployment user
* Install Docker Engine
* Configure Docker Hub authentication using Ansible Vault
* Pull and run a Docker container
* Install and configure Nginx
* Configure Nginx as a reverse proxy
* Perform application health checks

---

## 🏗️ Architecture

```text
                    Internet
                       │
                       ▼
                AWS EC2 Instance
                    Port 80
                       │
                       ▼
                  ┌─────────┐
                  │  Nginx  │
                  └────┬────┘
                       │
                Reverse Proxy
                       │
                       ▼
                 localhost:8080
                       │
                       ▼
              ┌─────────────────┐
              │ Docker Container │
              │      myapp       │
              │    nginx:latest  │
              └─────────────────┘
```

---

## 🛠️ Technologies Used

* AWS EC2
* Ubuntu Linux
* Ansible
* Ansible Roles
* Ansible Vault
* Docker
* Docker Hub
* Nginx
* Nginx Reverse Proxy
* YAML
* Bash

---

## 📁 Project Structure

```text
ansible-docker-project/
├── ansible.cfg
├── inventory.ini
├── site.yml
├── .gitignore
├── .vault_pass
│
├── group_vars/
│   ├── all.yml
│   └── web/
│       ├── vars.yml
│       └── vault.yml
│
└── roles/
    ├── common/
    │   └── tasks/
    │       └── main.yml
    │
    ├── docker/
    │   ├── defaults/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   ├── tasks/
    │   │   └── main.yml
    │   └── templates/
    │       └── docker-compose.yml.j2
    │
    └── nginx/
        ├── defaults/
        │   └── main.yml
        ├── handlers/
        │   └── main.yml
        ├── tasks/
        │   └── main.yml
        └── templates/
            ├── nginx.conf.j2
            └── app-proxy.conf.j2
```

---

# 1. Common Role

The `common` role prepares the server.

### Tasks performed

* Set timezone
* Update APT cache
* Install common packages
* Set hostname
* Create `deploy` user

Packages installed include:

```text
vim
curl
wget
git
htop
tree
jq
unzip
```

---

# 2. Docker Role

The Docker role automates Docker installation and application deployment.

### Docker installation

The role:

1. Installs Docker dependencies
2. Creates the Docker keyring directory
3. Downloads the Docker GPG key
4. Adds the official Docker repository
5. Installs Docker Engine
6. Enables and starts Docker

Installed components include:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

---

# 3. Docker User Configuration

The `deploy` user is added to the Docker group:

```bash
docker
```

This allows the deployment user to interact with Docker without requiring root privileges.

---

# 4. Ansible Vault

Docker Hub credentials are stored securely using **Ansible Vault**.

The encrypted file is:

```text
group_vars/web/vault.yml
```

The Vault file contains variables such as:

```yaml
vault_docker_username: ...
vault_docker_password: ...
```

The actual credentials are never stored in plaintext in Git.

The Vault password file is:

```text
.vault_pass
```

It is excluded from Git using:

```text
.vault_pass
```

in `.gitignore`.

---

# 5. Docker Image Deployment

The Docker role pulls the application image:

```text
nginx:latest
```

The container is named:

```text
myapp
```

Port mapping:

```text
8080:80
```

Therefore:

```text
EC2 localhost:8080
        ↓
Docker myapp container
        ↓
Nginx container port 80
```

---

# 6. Application Health Check

Ansible verifies that the Docker application is responding:

```text
http://localhost:8080
```

The health check retries the request if necessary.

This ensures Ansible doesn't simply start the container but also verifies that the application is actually responding.

---

# 7. Nginx Role

The Nginx role installs and configures Nginx.

The default Nginx site is removed:

```text
/etc/nginx/sites-enabled/default
```

A custom reverse proxy configuration is created:

```text
/etc/nginx/conf.d/devops-app.conf
```

---

# 8. Reverse Proxy Configuration

Nginx listens on:

```text
Port 80
```

and forwards requests to:

```text
127.0.0.1:8080
```

The flow is:

```text
Client
  ↓
EC2 Port 80
  ↓
Nginx
  ↓
127.0.0.1:8080
  ↓
Docker Container
  ↓
Application
```

---

# 9. Nginx Health Endpoint

A `/health` endpoint was configured.

Request:

```bash
curl http://EC2_PUBLIC_IP/health
```

Response:

```text
OK
```

This provides a simple way to verify that Nginx is running and responding.

---

# 10. Ansible Playbook

The main playbook is:

```text
site.yml
```

It executes three roles:

```yaml
- common
- docker
- nginx
```

The execution flow is:

```text
Common Configuration
        ↓
Docker Installation & Application
        ↓
Nginx Reverse Proxy
```

---

# 11. Syntax Validation

The playbook was validated using:

```bash
ansible-playbook -i inventory.ini --syntax-check site.yml
```

Result:

```text
playbook: site.yml
```

---

# 12. Full Deployment

The complete infrastructure was deployed using:

```bash
ansible-playbook -i inventory.ini site.yml
```

Final result:

```text
PLAY RECAP

app-server : ok=25
changed=0
unreachable=0
failed=0
skipped=0
rescued=0
ignored=0
```

The playbook completed successfully.

---

# 13. Idempotency

The second full execution produced:

```text
changed=0
```

This demonstrates **Ansible idempotency**.

Ansible checked the existing configuration and did not make unnecessary changes.

This is an important characteristic of configuration management.

---

# 14. Verification

### Check Ansible connectivity

```bash
ansible web -i inventory.ini -m ping
```

Expected:

```text
SUCCESS
pong
```

### Check Docker

```bash
docker ps
```

Expected container:

```text
myapp
```

### Check Nginx

```bash
systemctl is-active nginx
```

Expected:

```text
active
```

### Check application

```bash
curl http://EC2_PUBLIC_IP
```

Expected:

```text
Nginx response
```

### Check health endpoint

```bash
curl http://EC2_PUBLIC_IP/health
```

Expected:

```text
OK
```

---

# 15. What I Learned

Through this project I learned:

* How Ansible roles organize automation
* How to create custom roles
* How Ansible variables work
* How to use Jinja2 templates
* How to use Ansible handlers
* How to install Docker using Ansible
* How to manage Docker containers with Ansible
* How to use Ansible Vault for secrets
* How to configure Nginx using Ansible
* How reverse proxies work
* How Docker port mapping works
* How to perform automated health checks
* How Ansible idempotency works
* How to deploy infrastructure repeatedly using automation

---

# 🎯 Interview Questions

### 1. What is Ansible?

Ansible is an open-source automation and configuration-management tool used to automate server configuration, application deployment, and infrastructure tasks.

### 2. Why did you use Ansible roles?

Roles provide a structured and reusable way to organize Ansible automation.

In this project I separated the configuration into:

```text
common
docker
nginx
```

### 3. What is Ansible Vault?

Ansible Vault is used to encrypt sensitive information such as passwords, API keys, and access tokens.

### 4. What is a reverse proxy?

A reverse proxy receives requests from clients and forwards them to backend services.

In this project:

```text
Client → Nginx → Docker Application
```

### 5. Why use Nginx in front of Docker?

Nginx provides a single public entry point on port 80 and forwards requests to the application running inside the Docker container.

### 6. What is idempotency?

Idempotency means repeatedly running the same Ansible playbook produces the desired state without making unnecessary changes.

In this project the second execution showed:

```text
changed=0
```

### 7. What happens when a user accesses port 80?

The request reaches the EC2 instance and is handled by Nginx.

Nginx forwards the request to:

```text
127.0.0.1:8080
```

Docker maps port `8080` on the host to port `80` inside the container.

---

# 🚀 Final Result

The project successfully automates:

```text
Linux Server Configuration
        ↓
Docker Installation
        ↓
Docker Authentication
        ↓
Docker Image Pull
        ↓
Container Deployment
        ↓
Nginx Installation
        ↓
Reverse Proxy Configuration
        ↓
Application Health Check
```

This project demonstrates practical knowledge of **Ansible + AWS EC2 + Docker + Nginx + Ansible Vault**.

# Day 09 - Linux User & Group Management Challenge

## Objective

Learn how to create users, groups, assign permissions, and manage shared directories in Linux.

---

## Users & Groups Created

### Users

- tokyo
- berlin
- professor
- nairobi

### Groups

- developers
- admins
- project-team

---

## Group Assignments

- tokyo → developers, project-team
- berlin → developers, admins
- professor → admins
- nairobi → project-team

---

## Directories Created

### /opt/dev-project

- Group Owner: developers
- Permissions: 775

### /opt/team-workspace

- Group Owner: project-team
- Permissions: 775

---

## Commands Used

```bash
sudo useradd -m tokyo
sudo useradd -m berlin
sudo useradd -m professor
sudo useradd -m nairobi

sudo passwd tokyo
sudo passwd berlin
sudo passwd professor
sudo passwd nairobi

sudo groupadd developers
sudo groupadd admins
sudo groupadd project-team

sudo usermod -aG developers tokyo
sudo usermod -aG developers,admins berlin
sudo usermod -aG admins professor
sudo usermod -aG project-team nairobi
sudo usermod -aG project-team tokyo

sudo mkdir -p /opt/dev-project
sudo mkdir -p /opt/team-workspace

sudo chgrp developers /opt/dev-project
sudo chgrp project-team /opt/team-workspace

sudo chmod 775 /opt/dev-project
sudo chmod 775 /opt/team-workspace

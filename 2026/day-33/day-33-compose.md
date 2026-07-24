# Day 33 – Docker Compose: Multi-Container Basics

## 🎯 Objective

The goal of this lab was to learn Docker Compose and understand how to deploy and manage multi-container applications using a single `docker-compose.yml` file.

---

# Task 1 – Install & Verify Docker Compose

## Commands Used

```bash
docker --version
docker compose version
```

## Output

- Docker Engine Version: **29.1.3**
- Docker Compose Version: **2.40.3**

## Screenshot

![Compose Version](screenshots/01-compose-version.png)

---

# Task 2 – First Docker Compose Project (Nginx)

## Folder Structure

```text
compose-basics/
└── docker-compose.yml
```

## docker-compose.yml

```yaml
services:
  nginx:
    image: nginx:latest
    container_name: nginx-compose
    ports:
      - "8085:80"
```

## Commands Used

```bash
docker compose up -d
docker ps
docker compose down
```

## Browser

```
http://localhost:8085
```

The Nginx Welcome page was displayed successfully.

## Screenshots

![Compose Up](screenshots/02-compose-up.png)

![Nginx Browser](screenshots/03-nginx-browser.png)

---

# Challenge Faced

While starting the Nginx container, I received the following error:

```text
failed to bind host port 8080: address already in use
```

## Root Cause

Port **8080** was already being used by the Jenkins service.

## Solution

Changed the port mapping from:

```yaml
8080:80
```

to

```yaml
8085:80
```

The container started successfully after changing the host port.

---

# Task 3 – WordPress + MySQL

## Folder Structure

```text
wordpress-mysql/
├── docker-compose.yml
└── .env
```

## .env

```env
MYSQL_ROOT_PASSWORD=root123
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wp123
```

## Services

- WordPress
- MySQL
- Named Volume
- Docker Network
- Environment Variables

## Commands Used

```bash
docker compose up -d
docker ps
```

## Browser

```
http://localhost:8081
```

Successfully installed WordPress and created a sample website.

## Screenshots

![WordPress Dashboard](screenshots/04-wordpress-dashboard.png)

![WordPress Home](screenshots/05-wordpress-homepage.png)

---

# Data Persistence Test

## Commands

```bash
docker compose down

docker compose up -d

docker ps
```

## Result

After stopping and recreating the containers, WordPress loaded normally without asking for installation again.

This confirmed that the MySQL named volume preserved the database data.

## Screenshots

![Docker PS](screenshots/15-docker-ps.png)

![Persistence](screenshots/16-volume-persistence.png)

---

# Task 4 – Docker Compose Commands

## View Running Containers

```bash
docker compose ps
```

![Compose PS](screenshots/06-compose-ps.png)

---

## View Logs

```bash
docker compose logs
```

![Compose Logs](screenshots/07-compose-logs-all.png)

---

## WordPress Logs

```bash
docker compose logs wordpress
```

![WordPress Logs](screenshots/08-wordpress-logs.png)

---

## MySQL Logs

```bash
docker compose logs db
```

![MySQL Logs](screenshots/09-mysql-logs.png)

---

## Stop Services

```bash
docker compose stop
```

![Compose Stop](screenshots/10-compose-stop.png)

---

## Start Services

```bash
docker compose start
```

![Compose Start](screenshots/11-compose-start.png)

---

## Restart Services

```bash
docker compose restart
```

![Compose Restart](screenshots/12-compose-restart.png)

---

## Remove Containers

```bash
docker compose down
```

![Compose Down](screenshots/13-compose-down.png)

---

## Start Again

```bash
docker compose up -d
```

![Compose Up Again](screenshots/14-compose-up-again.png)

---

# Task 5 – Environment Variables

## Verify Configuration

```bash
docker compose config
```

Docker Compose successfully loaded all variables from the `.env` file.

## Screenshot

![Compose Config](screenshots/17-compose-config.png)

---

# What I Learned

- Docker Compose simplifies multi-container deployments.
- A single YAML file can define multiple services.
- Docker Compose automatically creates networks.
- Containers communicate using service names.
- Named volumes provide persistent storage.
- Environment variables can be managed using a `.env` file.
- Docker Compose commands make container management easier.

---

# Conclusion

Today I learned how to use Docker Compose to deploy both single-container and multi-container applications. I successfully configured Nginx, WordPress, and MySQL, verified persistent storage using Docker volumes, practiced essential Docker Compose commands, and gained hands-on experience with a real-world multi-container setup.

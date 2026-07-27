# Day 36 – Docker Project: Dockerize a Full Application

## 📌 Objective

The objective of this project is to Dockerize a complete Python Flask application with a PostgreSQL database using Docker and Docker Compose. The application is containerized, configured using environment variables, and published to Docker Hub.

---

# 📖 Project Overview

In this project, I created a simple **Employee Management App** using **Flask** and **PostgreSQL**.

The application checks the database connection and displays the connection status on a web page.

The complete application is containerized using Docker and orchestrated with Docker Compose.

---

# 🛠 Technologies Used

- Docker
- Docker Compose
- Python 3.12
- Flask
- PostgreSQL 16 (Alpine)
- Docker Hub
- Git & GitHub

---

# 📁 Project Structure

```text
day-36/
├── README.md
├── day-36-docker-project.md
├── flask-postgres-app/
│   ├── app.py
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── .dockerignore
│   ├── .env
│   ├── requirements.txt
│   ├── init.sql
│   └── templates/
│       └── index.html
└── pictures/
    └── screenshots/
        ├── 01-docker-images.png
        └── 02-flask-app-browser.png
```

---

# 🚀 Application Features

- Flask Web Application
- PostgreSQL Database
- Dockerized Application
- Docker Compose Configuration
- Persistent Database Storage
- Environment Variables
- Database Health Check
- Custom Docker Network
- Docker Hub Image

---

# 🐳 Dockerfile Explanation

The Dockerfile performs the following tasks:

- Uses `python:3.12-slim` as the base image.
- Creates the application working directory.
- Copies the `requirements.txt` file.
- Installs all Python dependencies.
- Creates a non-root user for improved security.
- Copies the application source code.
- Changes ownership of the application directory.
- Starts the Flask application.

---

# 📦 Docker Compose Configuration

The Docker Compose file contains two services:

## 1. App Service

- Builds/Runs the Flask application
- Exposes Port **5001**
- Loads environment variables from `.env`
- Waits until PostgreSQL becomes healthy

## 2. Database Service

- PostgreSQL 16 Alpine
- Persistent Docker Volume
- Health Check using `pg_isready`
- Database initialization using `init.sql`

---

# 🌍 Environment Variables

```env
DB_NAME=employee
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=db
```

---

# 🔨 Build the Project

```bash
docker compose build
```

---

# ▶️ Run the Project

```bash
docker compose up -d
```

---

# 🌐 Access the Application

Open your browser:

```
http://localhost:5001
```

Expected Output:

```
Employee Management App

Database Status

✅ Connected Successfully to PostgreSQL!
```

---

# 🐳 Docker Hub

Docker Image:

```
shraddhawankhade/employee-app:v1
```

Docker Hub Repository:

```
https://hub.docker.com/r/shraddhawankhade/employee-app
```

---

# 🧪 Testing

## Local Build

Successfully built the application using Docker Compose.

## Docker Hub Test

Successfully removed the local image.

Pulled the image from Docker Hub.

Ran the application successfully using:

```bash
docker compose up -d
```

The application worked correctly after pulling the image from Docker Hub.

---

# ⚠ Challenges Faced

### Challenge 1

Dockerfile was empty.

### Solution

Created a proper Dockerfile with Python slim image.

---

### Challenge 2

`app.py` was empty.

### Solution

Implemented the Flask application and database connection.

---

### Challenge 3

Environment variables were missing.

### Solution

Created the `.env` file and configured Docker Compose to use it.

---

### Challenge 4

Port **5000** was already in use.

### Solution

Changed the application port to **5001**.

---

### Challenge 5

Verified Docker Hub deployment.

### Solution

Removed the local image and successfully pulled the image from Docker Hub.

---

# 📸 Screenshots

## Docker Images

**File:**

```
pictures/screenshots/01-docker-images.png
```

---

## Flask Application Output

**File:**

```
pictures/screenshots/02-flask-app-browser.png
```

---

# 🎯 Learning Outcomes

- Learned how to Dockerize a Flask application.
- Connected Flask with PostgreSQL.
- Used Docker Compose for multi-container applications.
- Used Docker Volumes for persistent storage.
- Configured environment variables using `.env`.
- Implemented PostgreSQL health checks.
- Published Docker images to Docker Hub.
- Verified deployment by pulling images from Docker Hub.

---

# ✅ Conclusion

Successfully Dockerized a complete Flask + PostgreSQL application using Docker and Docker Compose.

The application was tested locally, pushed to Docker Hub, and successfully deployed by pulling the image from Docker Hub, demonstrating an end-to-end containerized workflow.

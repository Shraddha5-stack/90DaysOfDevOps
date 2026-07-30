# 🐳 Docker Cheat Sheet

A quick reference guide for commonly used Docker commands and Dockerfile instructions.

---

# 📦 Container Commands

| Command | Description |
|----------|-------------|
| `docker run <image>` | Run a container from an image |
| `docker run -it ubuntu bash` | Start an interactive Ubuntu container |
| `docker run -d nginx` | Run a container in detached mode |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker stop <container>` | Stop a running container |
| `docker start <container>` | Start a stopped container |
| `docker restart <container>` | Restart a container |
| `docker rm <container>` | Remove a container |
| `docker exec -it <container> bash` | Open a shell inside a running container |
| `docker logs <container>` | View container logs |
| `docker inspect <container>` | Display detailed container information |

---

# 🖼️ Image Commands

| Command | Description |
|----------|-------------|
| `docker images` | List all images |
| `docker pull <image>` | Download an image from Docker Hub |
| `docker build -t myapp .` | Build an image from a Dockerfile |
| `docker tag image:tag username/image:tag` | Tag an image |
| `docker push username/image:tag` | Push an image to Docker Hub |
| `docker rmi <image>` | Remove an image |
| `docker image inspect <image>` | Show image details |

---

# 💾 Volume Commands

| Command | Description |
|----------|-------------|
| `docker volume create myvolume` | Create a named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect myvolume` | View volume details |
| `docker volume rm myvolume` | Remove a volume |

---

# 🌐 Network Commands

| Command | Description |
|----------|-------------|
| `docker network create my-network` | Create a custom network |
| `docker network ls` | List networks |
| `docker network inspect my-network` | Inspect a network |
| `docker network connect my-network container` | Connect a container to a network |
| `docker network rm my-network` | Remove a network |

---

# 🧩 Docker Compose Commands

| Command | Description |
|----------|-------------|
| `docker compose up` | Start services |
| `docker compose up -d` | Start services in detached mode |
| `docker compose down` | Stop and remove containers |
| `docker compose down -v` | Remove containers and volumes |
| `docker compose ps` | List Compose services |
| `docker compose logs` | View service logs |
| `docker compose build` | Build service images |
| `docker compose restart` | Restart services |

---

# 🧹 Cleanup Commands

| Command | Description |
|----------|-------------|
| `docker system df` | Show Docker disk usage |
| `docker system prune` | Remove unused Docker resources |
| `docker image prune` | Remove unused images |
| `docker container prune` | Remove stopped containers |
| `docker volume prune` | Remove unused volumes |
| `docker network prune` | Remove unused networks |

---

# 📝 Dockerfile Instructions

| Instruction | Purpose |
|-------------|---------|
| `FROM` | Base image |
| `WORKDIR` | Set working directory |
| `COPY` | Copy files into the image |
| `ADD` | Copy files and extract archives or download URLs |
| `RUN` | Execute commands during image build |
| `ENV` | Set environment variables |
| `EXPOSE` | Document the application port |
| `CMD` | Default command executed when the container starts |
| `ENTRYPOINT` | Main executable for the container |
| `USER` | Run the container as a specific user |

---

# ⚡ Common Docker Workflow

```bash
# Pull an image
docker pull nginx

# Run a container
docker run -d -p 8080:80 nginx

# Check running containers
docker ps

# View logs
docker logs <container>

# Stop the container
docker stop <container>

# Remove the container
docker rm <container>

# Build an image
docker build -t myapp .

# Tag the image
docker tag myapp username/myapp:v1

# Push to Docker Hub
docker push username/myapp:v1
```

---

# 📌 Useful Tips

- Use **Docker Volumes** for persistent data.
- Use **Bind Mounts** during development.
- Prefer **Alpine** or **Slim** images to reduce image size.
- Use a **.dockerignore** file to exclude unnecessary files.
- Store secrets and configuration in a **.env** file.
- Use **Docker Compose** for multi-container applications.
- Use **Health Checks** to ensure services are ready before dependent containers start.
- Use **Multi-stage Builds** to create smaller production images.

---

# 🎯 Interview Tips

- Know the difference between an **Image** and a **Container**.
- Understand **CMD vs ENTRYPOINT**.
- Explain **Docker Volumes vs Bind Mounts**.
- Understand **Docker Networking**.
- Know how **Docker Compose** works.
- Practice pushing and pulling images from Docker Hub.
- Learn Dockerfile best practices for production.

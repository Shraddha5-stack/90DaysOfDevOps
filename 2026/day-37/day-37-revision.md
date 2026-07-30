# Day 37 – Docker Revision & Self-Assessment

## 🎯 Goal

Today's goal was to revise everything learned from **Day 29 to Day 36** and strengthen my understanding of Docker fundamentals, Docker Compose, Docker Hub, networking, volumes, and Dockerfile best practices.

---

# ✅ Self-Assessment Checklist

| Topic | Status |
|--------|--------|
| Run a container from Docker Hub (interactive + detached) | ✅ Can Do |
| List, stop, remove containers and images | ✅ Can Do |
| Explain image layers and Docker build cache | ✅ Can Do |
| Write a Dockerfile from scratch | ✅ Can Do |
| Explain CMD vs ENTRYPOINT | 🟡 Shaky |
| Build and tag a custom image | ✅ Can Do |
| Create and use named volumes | ✅ Can Do |
| Use bind mounts | ✅ Can Do |
| Create custom networks and connect containers | ✅ Can Do |
| Write a docker-compose.yml for a multi-container application | ✅ Can Do |
| Use environment variables and .env files | ✅ Can Do |
| Write a multi-stage Dockerfile | 🟡 Shaky |
| Push an image to Docker Hub | ✅ Can Do |
| Use healthchecks and depends_on | ✅ Can Do |

### Status Legend

- ✅ Can Do
- 🟡 Shaky
- ❌ Haven't Done

---

# ⚡ Quick-Fire Questions

## 1. What is the difference between an image and a container?

**Answer:**

- A Docker Image is a read-only template that contains the application, dependencies, libraries, and configuration.
- A Docker Container is a running instance of an image.

---

## 2. What happens to data inside a container when you remove it?

**Answer:**

Data stored inside the container is deleted when the container is removed unless it is stored in a Docker Volume or a Bind Mount.

---

## 3. How do two containers on the same custom network communicate?

**Answer:**

Containers on the same custom Docker network communicate using their container or service names through Docker's built-in DNS.

---

## 4. What does `docker compose down -v` do differently from `docker compose down`?

**Answer:**

- `docker compose down` removes containers and networks.
- `docker compose down -v` removes containers, networks, and associated Docker volumes.

---

## 5. Why are multi-stage builds useful?

**Answer:**

Multi-stage builds reduce image size by excluding build tools and unnecessary files from the final production image.

---

## 6. What is the difference between COPY and ADD?

**Answer:**

- `COPY` copies files and directories into the image.
- `ADD` can also extract local archives and download files from URLs.

---

## 7. What does `-p 8080:80` mean?

**Answer:**

It maps port **8080** on the host machine to port **80** inside the container.

---

## 8. How do you check how much disk space Docker is using?

**Answer:**

```bash
docker system df
```

---

# 🔁 Weak Areas

During today's revision, I identified the following topics that need more practice:

- CMD vs ENTRYPOINT
- Multi-stage Dockerfile

I plan to revisit these topics with additional hands-on examples.

---

# 📚 Topics Revised

- Docker Images
- Docker Containers
- Dockerfile
- Docker Compose
- Docker Networking
- Docker Volumes
- Bind Mounts
- Environment Variables
- Docker Hub
- Health Checks
- Docker Cleanup Commands

---

# 💡 Key Learnings

- Docker Images are immutable templates.
- Containers are running instances of images.
- Docker Volumes provide persistent storage.
- Docker Compose simplifies multi-container applications.
- Custom networks allow secure communication between containers.
- Health checks ensure dependent services start only after they are ready.
- Docker Hub makes image sharing and deployment easier.

---

# 🎯 Revision Outcome

Today's revision improved my confidence in Docker fundamentals and reinforced the concepts learned during Days 29–36. I also identified a few areas for further practice, especially **CMD vs ENTRYPOINT** and **Multi-stage Dockerfiles**, which I will continue to strengthen through hands-on exercises.

---

## ✅ Day 37 Completed

- Docker Self-Assessment ✔️
- Quick-Fire Questions ✔️
- Docker Revision ✔️
- Docker Cheat Sheet Created ✔️

🚀 Ready to move on to the next stage of my DevOps journey!

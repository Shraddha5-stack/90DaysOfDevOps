# Day 35 – Multi-Stage Builds & Docker Hub

## Objective

The goal of Day 35 is to learn how to build optimized Docker images using Multi-Stage Builds and publish container images to Docker Hub. This approach helps create smaller, faster, and more secure Docker images that are commonly used in production environments.

---

# Learning Outcomes

- Understand the difference between Single-Stage and Multi-Stage builds.
- Reduce Docker image size.
- Push Docker images to Docker Hub.
- Manage image tags.
- Apply Docker image best practices.
- Build production-ready container images.

---

# Project Structure

```
day-35/
│
├── app/
│   ├── app.js
│   └── package.json
│
├── single-stage/
│   └── Dockerfile
│
├── multi-stage/
│   └── Dockerfile
│
├── screenshots/
│
└── day-35-multistage-hub.md
```

---

# Task 1 – Single-Stage Docker Build

## Dockerfile

```dockerfile
FROM node:22

WORKDIR /app

COPY app/ .

CMD ["node","app.js"]
```

## Build Image

```bash
docker build -f single-stage/Dockerfile -t node-single:v1 .
```

## Run Container

```bash
docker run --rm node-single:v1
```

Output

```
Hello from Docker Day 35 🚀
```

## Image Size

```bash
docker image ls node-single
```

Approximate Size

```
1.62 GB
```

---

# Task 2 – Multi-Stage Docker Build

## Dockerfile

```dockerfile
FROM node:22 AS builder

WORKDIR /app

COPY app/ .

FROM node:22-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app .

USER appuser

CMD ["node","app.js"]
```

## Build Image

```bash
docker build -f multi-stage/Dockerfile -t node-multistage:v1 .
```

## Run Container

```bash
docker run --rm node-multistage:v1
```

Output

```
Hello from Docker Day 35 🚀
```

## Image Size

```bash
docker image ls node-multistage
```

Approximate Size

```
230 MB
```

---

# Image Size Comparison

| Image | Size |
|--------|------|
| Single Stage | 1.62 GB |
| Multi Stage | 230 MB |

### Why is the Multi-Stage Image Smaller?

- Removes unnecessary build dependencies.
- Keeps only the application files.
- Uses a lightweight Alpine base image.
- Reduces storage requirements.
- Faster to download and deploy.
- Improves security by reducing the attack surface.

---

# Task 3 – Push Images to Docker Hub

## Login

```bash
docker login
```

## Tag Images

```bash
docker tag node-single:v1 shraddhawankhade/node-single:v1

docker tag node-multistage:v1 shraddhawankhade/node-multistage:v1
```

## Push Images

```bash
docker push shraddhawankhade/node-single:v1

docker push shraddhawankhade/node-multistage:v1
```

Docker Hub Repository

```
shraddhawankhade/node-single

shraddhawankhade/node-multistage
```

---

# Task 4 – Docker Hub Repository

Verified the uploaded images successfully.

Explored:

- Repository page
- Tags
- Image details
- Latest tag
- Version tags

Pulled image using:

```bash
docker pull shraddhawankhade/node-multistage:v1
```

Created latest tag

```bash
docker tag node-multistage:v1 shraddhawankhade/node-multistage:latest

docker push shraddhawankhade/node-multistage:latest
```

---

# Task 5 – Docker Image Best Practices

Applied the following best practices:

- Used Alpine base image.
- Used Multi-Stage Build.
- Added a non-root user.
- Used a specific base image tag.
- Reduced image size significantly.
- Created a production-ready Docker image.

---

# Commands Used

```bash
docker build

docker run

docker image ls

docker login

docker tag

docker push

docker pull
```

---

# Screenshot References

| Screenshot | Description |
|------------|-------------|
| 01-single-stage-image-size.png | Single-stage image size |
| 02-single-stage-run.png | Single-stage container execution |
| 03-single-vs-multistage-size.png | Image size comparison |
| 04-multi-stage-run.png | Multi-stage container execution |
| 05-docker-images-comparison.png | Docker images list |
| 06-docker-push-v1.png | Docker push (v1) |
| 07-dockerhub-repositories.png | Docker Hub repositories |
| 08-dockerhub-image-details.png | Docker Hub image details |
| 09-docker-push-latest.png | Latest tag push |
| 10-best-practice-dockerfile.png | Optimized Dockerfile |
| 11-best-practice-image.png | Best-practice image |

---

# Real-World Use Cases

- Microservices deployment
- Kubernetes workloads
- CI/CD pipelines
- Cloud-native applications
- Production Docker images
- DevOps automation

---

# Interview Questions

### What is a Multi-Stage Build?

A Multi-Stage Build uses multiple `FROM` statements in a Dockerfile to separate the build environment from the runtime environment. It copies only the required application artifacts into the final image, resulting in a smaller, cleaner, and more secure image.

---

### Why should we use Multi-Stage Builds?

- Smaller images
- Faster deployments
- Improved security
- Cleaner Dockerfiles
- Reduced storage usage

---

### Why is Alpine preferred?

Alpine Linux is a lightweight Linux distribution with a very small footprint, making Docker images smaller and faster to download.

---

### What is Docker Hub?

Docker Hub is a cloud-based container registry used to store, manage, version, and distribute Docker images.

---

### Difference between `latest` and `v1` tags?

- `latest` usually represents the newest version.
- `v1` is a fixed version that does not change.

Version tags are preferred for production deployments.

---

# Key Learnings

- Built Single-Stage Docker images.
- Built Multi-Stage Docker images.
- Reduced image size from approximately **1.62 GB** to **230 MB**.
- Pushed Docker images to Docker Hub.
- Worked with image tags (`v1` and `latest`).
- Applied Docker image optimization techniques.
- Learned production-ready Docker image best practices.

---

# Conclusion

Day 35 introduced production-ready Docker image optimization using Multi-Stage Builds and Docker Hub. By reducing image size, improving security, and following Docker best practices, we created lightweight images that are easier to distribute, deploy, and maintain in real-world DevOps environments.

# Day 39 - What is CI/CD?

## 🎯 Goal

Understand the fundamentals of Continuous Integration (CI), Continuous Delivery (CD), and Continuous Deployment before writing any pipelines.

---

# Task 1: The Problem

## Imagine a Team of 5 Developers

Five developers are working on the same application. Everyone writes code and manually deploys it to the production server.

### What Can Go Wrong?

- Code conflicts between developers
- Bugs introduced into production
- Human errors during deployment
- Missing files or incorrect versions
- Different environments causing failures
- No automated testing before deployment
- Rollback becomes difficult
- Downtime for users

---

## What Does "It Works on My Machine" Mean?

"It works on my machine" means the application runs correctly on the developer's computer but fails on another developer's system or the production server.

### Why Does This Happen?

- Different operating systems
- Different software versions
- Missing dependencies
- Environment variable differences
- Database configuration differences

### Why Is It a Real Problem?

- Wastes debugging time
- Delays releases
- Causes production failures
- Reduces team productivity

---

## How Many Times Can a Team Safely Deploy Manually?

Usually only a few times per day.

Manual deployments become risky because:

- Human mistakes increase
- Testing takes time
- Every deployment requires manual effort
- Rollback is difficult

With CI/CD, teams can safely deploy dozens or even hundreds of times every day.

---

# Task 2: CI vs CD

## Continuous Integration (CI)

Continuous Integration is the practice of frequently merging code into a shared repository.

Every push automatically:

- Builds the application
- Runs automated tests
- Detects bugs early

### Real-World Example

A developer pushes code to GitHub.

GitHub Actions automatically:

- Installs dependencies
- Builds the application
- Runs unit tests

If tests fail, the merge is blocked.

---

## Continuous Delivery (CD)

Continuous Delivery automatically prepares software for release after successful testing.

The application is always ready to deploy, but a human approves the final deployment.

### Real-World Example

After CI succeeds:

- Docker image is created
- Image is stored in Docker Hub
- Staging server is updated

Production deployment happens only after clicking **Approve**.

---

## Continuous Deployment

Continuous Deployment automatically deploys every successful change to production.

There is **no manual approval**.

### Real-World Example

Developer pushes code →

Tests pass →

Docker image builds →

Production server updates automatically.

Companies like Netflix and Facebook use Continuous Deployment for many services.

---

# CI vs Continuous Delivery vs Continuous Deployment

| Feature | Continuous Integration | Continuous Delivery | Continuous Deployment |
|----------|-----------------------|--------------------|----------------------|
| Build Code | ✅ | ✅ | ✅ |
| Run Tests | ✅ | ✅ | ✅ |
| Create Release | ❌ | ✅ | ✅ |
| Manual Approval | ❌ | ✅ | ❌ |
| Automatic Production Deployment | ❌ | ❌ | ✅ |

---

# Task 3: Pipeline Anatomy

## Trigger

The event that starts the pipeline.

Examples:

- Git Push
- Pull Request
- Schedule
- Manual Run

---

## Stage

A major phase of the pipeline.

Examples:

- Build
- Test
- Deploy

---

## Job

A collection of related steps inside a stage.

Example:

Build Job

- Install dependencies
- Build application
- Package files

---

## Step

A single command or action.

Examples:

```bash
npm install
```

```bash
docker build .
```

```bash
pytest
```

---

## Runner

The machine that executes the pipeline.

Examples:

- GitHub Hosted Runner
- Jenkins Agent
- Self-hosted Runner

---

## Artifact

A file produced by the pipeline that is used later.

Examples:

- Docker Image
- ZIP package
- JAR file
- Binary executable
- Test Report

---

# Task 4: CI/CD Pipeline Diagram

```
             Developer
                 │
                 │
         git push to GitHub
                 │
                 ▼
     ┌──────────────────────┐
     │      Trigger         │
     └──────────────────────┘
                 │
                 ▼
     ┌──────────────────────┐
     │ Build Stage          │
     │----------------------│
     │ Install Dependencies │
     │ Build Application    │
     └──────────────────────┘
                 │
                 ▼
     ┌──────────────────────┐
     │ Test Stage           │
     │----------------------│
     │ Unit Tests           │
     │ Integration Tests    │
     └──────────────────────┘
                 │
                 ▼
     ┌──────────────────────┐
     │ Docker Build Stage   │
     │----------------------│
     │ docker build         │
     │ docker tag           │
     └──────────────────────┘
                 │
                 ▼
     ┌──────────────────────┐
     │ Deploy Stage         │
     │----------------------│
     │ Deploy to Staging    │
     └──────────────────────┘
                 │
                 ▼
          Staging Server
```

---

# Task 5: Explore in the Wild

## Repository Chosen

FastAPI

Workflow Folder

```
.github/workflows/
```

Workflow File

```
ci.yml
```

### What Triggers It?

- Push
- Pull Request

### How Many Jobs?

Approximately 3–5 jobs (depending on the workflow version).

Examples:

- Test
- Lint
- Documentation
- Build

### What Does It Do?

- Installs Python
- Installs project dependencies
- Runs formatting checks
- Runs linting
- Executes automated tests
- Verifies the project builds successfully

---

# Why CI/CD Matters

Without CI/CD

- Manual deployments
- Slow releases
- Human errors
- Bugs reach production
- Difficult rollback

With CI/CD

- Faster releases
- Automated testing
- Consistent deployments
- Better software quality
- Quick feedback
- Easier collaboration

---

# Key Takeaways

- CI/CD is a software development practice, not a tool.
- CI automatically builds and tests every code change.
- Continuous Delivery prepares software for release with manual approval.
- Continuous Deployment automatically releases successful changes to production.
- Pipelines reduce human error and improve software quality.
- A failed pipeline is a success because it prevents bad code from reaching users.

---

# Tools That Implement CI/CD

- GitHub Actions
- Jenkins
- GitLab CI/CD
- CircleCI
- Azure DevOps Pipelines
- Bitbucket Pipelines
- AWS CodePipeline

---

## Today's Learning

✅ Understood CI/CD concepts

✅ Learned pipeline anatomy

✅ Drew a CI/CD pipeline

✅ Explored a real GitHub Actions workflow

✅ Ready to build the first pipeline tomorrow 🚀

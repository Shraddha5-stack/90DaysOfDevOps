# Day 48 – GitHub Actions Project: End-to-End CI/CD Pipeline

## Project Overview

This project is my GitHub Actions CI/CD capstone project.

The goal is to combine the GitHub Actions concepts learned from Day 40 to Day 47 into one production-style CI/CD pipeline.

The pipeline will:

- Build and test the application
- Build and push a Docker image
- Run PR validation
- Deploy after successful builds
- Perform scheduled health checks
- Use reusable workflows
- Add security scanning

---

# Task 1 – Set Up the Project Repo

## Repository

Repository used for this project:

`github-actions-practice`

Instead of creating a new repository, I reused my existing GitHub Actions practice repository and extended it into a CI/CD capstone project.

## Application

The project contains a Dockerized application.

The repository includes:

- Application source code
- Dockerfile
- Test files/scripts
- GitHub Actions workflows
- README documentation

## Project Structure

```text
github-actions-practice/
│
├── .github/
│   └── workflows/
│       └── GitHub Actions workflow files
│
├── app/
│   └── Application files
│
├── Dockerfile
├── README.md
└── day-48-actions-project.md

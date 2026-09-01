# Day 60 – Kubernetes Capstone: WordPress + MySQL

## Objective

Deploy a complete WordPress + MySQL application on Kubernetes using the
major concepts learned during Days 50–59.

## Architecture

```text
                    ┌─────────────────────┐
                    │      Browser        │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ WordPress NodePort  │
                    │      Service        │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │ WordPress Deployment│
                    │                     │
                    │   Pod 1   Pod 2     │
                    └──────────┬──────────┘
                               │
                               │ MySQL DNS
                               ▼
                    ┌─────────────────────┐
                    │   MySQL Headless    │
                    │      Service        │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │    MySQL-0          │
                    │    StatefulSet      │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │        PVC          │
                    │      1Gi Storage     │
                    └─────────────────────┘
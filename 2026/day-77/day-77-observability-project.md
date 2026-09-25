# Day 77 — Observability Project: Full Stack with Docker Compose

## 📌 Project Overview

For Day 77 of my 90 Days of DevOps journey, I built a complete observability stack using Docker Compose.

The project combines **metrics, logs, and traces** into a single monitoring environment using:

* Docker Compose
* Prometheus
* Node Exporter
* cAdvisor
* Grafana
* Loki
* Promtail
* OpenTelemetry Collector
* A sample Notes application

The goal was to understand how modern DevOps observability systems collect, process, store, and visualize telemetry from applications and infrastructure.

---

## 🏗️ Architecture

```text
                         ┌─────────────────────┐
                         │     Notes App       │
                         │    Port: 8000       │
                         └──────────┬──────────┘
                                    │
                              OTLP telemetry
                                    │
                                    ▼
                       ┌────────────────────────┐
                       │  OpenTelemetry         │
                       │      Collector         │
                       │                        │
                       │  OTLP: 4317 / 4318     │
                       │  Metrics: 8889         │
                       └───────┬─────────┬──────┘
                               │         │
                         Metrics         │ Traces
                               │         │
                               ▼         ▼
                         Prometheus    Debug Exporter


 ┌──────────────────┐       ┌──────────────────┐
 │  Node Exporter   │──────▶│                  │
 │ Host Metrics     │       │                  │
 └──────────────────┘       │    Prometheus    │
                            │     :9090        │
 ┌──────────────────┐       │                  │
 │    cAdvisor      │──────▶│                  │
 │ Container Metrics│       └────────┬─────────┘
 └──────────────────┘                │
                                     │
                                     ▼
                              ┌──────────────┐
                              │   Grafana    │
                              │    :3000     │
                              └──────────────┘


 Docker Container Logs
          │
          ▼
 ┌──────────────────┐
 │     Promtail     │
 └────────┬─────────┘
          │
          ▼
 ┌──────────────────┐
 │       Loki       │
 │      :3100       │
 └────────┬─────────┘
          │
          ▼
       Grafana
```

---

# 🐳 Docker Compose Stack

The complete environment contains **8 services**:

| Service                 | Purpose                             |        Port |
| ----------------------- | ----------------------------------- | ----------: |
| Grafana                 | Visualization and dashboards        |        3000 |
| Prometheus              | Metrics collection and querying     |        9090 |
| Node Exporter           | Host-level metrics                  |        9100 |
| cAdvisor                | Container metrics                   | 8082 → 8080 |
| Loki                    | Log aggregation                     |        3100 |
| Promtail                | Docker log collection               |        9080 |
| OpenTelemetry Collector | Telemetry collection and processing | 4317 / 4318 |
| Notes App               | Sample instrumented application     |        8000 |

All services communicate through a dedicated Docker network:

```text
monitoring
```

Persistent Docker volumes are used for:

```text
prometheus_data
grafana_data
loki_data
```

---

# 📊 Metrics Pipeline

## Prometheus

Prometheus is responsible for collecting and querying metrics.

Configured scrape targets:

```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "docker"
    static_configs:
      - targets: ["cadvisor:8080"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

The scrape interval is:

```yaml
scrape_interval: 15s
```

### Validation

Prometheus targets were checked and all four configured targets were **UP**.

The Prometheus `up` query returned:

```text
prometheus       1
docker           1
node-exporter    1
otel-collector   1
```

Therefore:

```promql
sum(up)
```

returned:

```text
4
```

---

# 🖥️ Node Exporter

Node Exporter collects host-level metrics such as:

* CPU
* Memory`day-77-observability-project.md`.
* Filesystem
* Network
* Load
* Disk statistics

Example metric:

```promql
node_cpu_seconds_total
```

I verified CPU metrics through Grafana Explore.

---

# 📦 cAdvisor

cAdvisor provides container-level resource metrics.

It collects information such as:

* Container CPU usage
* Container memory usage
* Container filesystem usage
* Container lifecycle information

The host port `8080` was already occupied by Jenkins on my machine.

Therefore I used:

```yaml
ports:
  - "8082:8080"
```

This means:

```text
Host:      8082
Container: 8080
```

cAdvisor was successfully accessed through:

```text
http://localhost:8082
```

---

# 📝 Logging Pipeline

The logging architecture is:

```text
Docker Containers
       │
       ▼
    Promtail
       │
       ▼
      Loki
       │
       ▼
    Grafana
```

## Promtail

Promtail reads Docker container JSON logs from:

```text
/var/lib/docker/containers/*/*-json.log
```

and sends them to:

```text
http://loki:3100/loki/api/v1/push
```

The Docker pipeline stage is used to process Docker-formatted logs.

---

# 🗄️ Loki

Loki stores and indexes log streams.

The Loki server runs on:

```text
3100
```

The configuration uses:

```text
TSDB
schema v13
filesystem storage
```

Authentication is disabled for this local development project:

```yaml
auth_enabled: false
```

---

# 🔎 Grafana Log Exploration

Grafana was configured with both:

* Prometheus datasource
* Loki datasource

A Loki query used for application request logs was:

```logql
{job="docker"} |= "GET"
```

This successfully returned Docker logs in Grafana Explore.

---

# 🔭 OpenTelemetry

OpenTelemetry Collector was added to collect application telemetry.

The collector accepts OTLP through:

```text
gRPC: 4317
HTTP: 4318
```

The collector exposes Prometheus-compatible metrics on:

```text
8889
```

---

## OpenTelemetry Metrics Pipeline

```text
Application
     │
     ▼
OTLP
     │
     ▼
OpenTelemetry Collector
     │
     ▼
Prometheus Exporter
     │
     ▼
Prometheus
```

The collector configuration uses:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
```

Metrics are exported using:

```yaml
exporters:
  prometheus:
    endpoint: 0.0.0.0:8889
```

---

# 🔭 OpenTelemetry Traces

The Notes application was instrumented to send traces to:

```text
http://otel-collector:4317
```

The collector currently sends traces to the debug exporter.

This allowed me to verify that traces were successfully received by the collector.

The collector output showed:

```text
resource spans: 1
spans: 3
```

This confirmed successful trace ingestion.

> Trace storage and visualization using a backend such as Grafana Tempo can be added as a future production enhancement.

---

# 📝 Notes Application

A sample Notes application was included to generate real application traffic and telemetry.

The application runs on:

```text
http://localhost:8000
```

The application was successfully started and tested.

The application was also used to generate HTTP requests that appeared in Loki.

---

# 📈 Grafana Dashboard

Grafana was used as the central visualization layer.

The dashboard contains panels for infrastructure, containers, logs, and OpenTelemetry health.

The dashboard uses:

```text
Time range: Last 30 minutes
Auto refresh: 10 seconds
```

## Dashboard Panels

### Row 1 — Infrastructure

1. CPU Usage %
2. Memory Usage %
3. Disk Usage
4. Targets Up

### Row 2 — Containers

5. Container CPU Usage
6. Container Memory
7. Container Count

### Row 3 — Logs

8. App Logs
9. Error Rate
10. Log Volume

### Row 4 — Observability

11. Prometheus Scrape Duration
12. OTEL Collector Target Status

---

# 📊 Important Dashboard Queries

## CPU

```promql
100 *
(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) 
```

## Disk Usage

```promql
(
  1 -
  node_filesystem_avail_bytes{mountpoint="/var/lib"}
  /
  node_filesystem_size_bytes{mountpoint="/var/lib"}
) * 100
```

## Targets Up

```promql
sum(up)
```

Expected result:

```text
4
```

## Container CPU

```promql
100 *
sum by (id) (
  rate(container_cpu_usage_seconds_total{
    job="docker",
    id=~"/docker/[a-f0-9]+"
  }[5m])
)
```

## Container Memory

```promql
container_memory_usage_bytes{
  job="docker",
  id=~"/docker/[a-f0-9]+"
} / 1024 / 1024
```

## Container Count

```promql
count(
  container_last_seen{
    job="docker",
    id=~"/docker/[a-f0-9]+"
  }
)
```

The dashboard showed:

```text
Container Count = 8
```

## Application Logs

```logql
{job="docker"} |= "GET"
```

## Error Rate

```logql
sum(rate({job="docker"} |= "error" [5m]))
```

## Log Volume

```logql
sum(rate({job="docker"}[5m]))
```

## Prometheus Scrape Duration

```promql
prometheus_target_interval_length_seconds{quantile="0.99"}
```

## OpenTelemetry Collector Health

```promql
up{job="otel-collector"}
```

Result:

```text
1
```

This panel represents the **health of the OpenTelemetry Collector Prometheus target**. It should not be interpreted as the number of metrics received.

---

# 🖥️ Production Overview

The final Grafana dashboard provided a single overview of:

* Host CPU
* Host memory
* Disk usage
* Prometheus target health
* Container CPU
* Container memory
* Container count
* Application logs
* Error rate
* Log volume
* Prometheus scrape performance
* OpenTelemetry Collector health

---

# 🧪 Validation

The complete stack was validated using Docker Compose:

```bash
docker compose ps
```

All 8 services were running successfully.

The main validation checks were:

```text
✓ Docker Compose stack running
✓ Prometheus running
✓ Prometheus targets UP
✓ Node Exporter metrics available
✓ cAdvisor metrics available
✓ Grafana running
✓ Loki receiving logs
✓ Promtail forwarding Docker logs
✓ Notes application accessible
✓ OpenTelemetry Collector running
✓ OTLP traces received
✓ Grafana dashboards working
```

---

# 🛠️ Problems Encountered and Solutions

## 1. cAdvisor Port Conflict

### Problem

Port `8080` was already being used by Jenkins.

### Solution

Changed the host mapping from:

```text
8080:8080
```

to:

```text
8082:8080
```

The cAdvisor container continued listening on port `8080`, while the host exposed it through `8082`.

---

## 2. Docker Compose Configuration Validation

A Compose validation error occurred because of incorrect YAML nesting.

The configuration was corrected and validated using:

```bash
docker compose config
```

---

## 3. Existing Container Conflicts

Some services from an earlier observability environment were already running.

This caused container and port conflicts.

I identified the existing containers and stopped the conflicting stack before starting the Day 77 environment.

Persistent volumes were preserved.

---

## 4. Loki Query Returned No Data

An initial Loki query depended on a specific Docker container ID.

Docker container IDs can change when containers are recreated.

The query was changed to a stable label-based query:

```logql
{job="docker"} |= "GET"
```

This successfully displayed application request logs.

---

## 5. OpenTelemetry Metric Panel Had No Data

The original metric:

```promql
otelcol_receiver_accepted_metric_points
```

did not return data in the current configuration.

Instead of presenting an incorrect metric, the dashboard uses:

```promql
up{job="otel-collector"}
```

This verifies that the OpenTelemetry Collector's Prometheus endpoint is reachable and healthy.

---

# 🔐 Production Readiness Improvements

The current project is designed as a local learning and portfolio environment.

For production deployment, I would add:

## 1. Trace Storage

Add Grafana Tempo or another distributed tracing backend.

```text
Application
     ↓
OTEL Collector
     ↓
Tempo
     ↓
Grafana
```

## 2. Alerting

Add:

* Alertmanager
* Grafana Alerting
* Alert routing
* Email/Slack/PagerDuty integrations

## 3. Security

Production environments should use:

* TLS
* Authentication
* Authorization
* Secret management
* Network policies

## 4. Persistent Storage

For production:

* Object storage for Loki
* Durable Prometheus storage
* Backup strategy
* Retention policies

## 5. High Availability

Production monitoring systems should consider:

* Highly available Prometheus architecture
* Loki scalability
* Multiple collectors
* Load balancing
* Failure recovery

## 6. Infrastructure as Code

The stack could be deployed using:

* Terraform
* Ansible
* Kubernetes
* Helm

## 7. Dashboard as Code

Grafana dashboards and datasource configuration can be version controlled and provisioned automatically.

---

# 📁 Project Structure

```text
observability-for-devops/
│
├── docker-compose.yml
├── prometheus.yml
│
├── grafana/
│   └── provisioning/
│
├── loki/
│   └── loki-config.yml
│
├── promtail/
│   └── promtail-config.yml
│
├── otel-collector/
│   └── otel-collector-config.yml
│
├── notes-app/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app.py
│   └── wsgi.py
│
└── assets/
    └── day-77/
```

---

# 📸 Project Screenshots

| #  | Screenshot                          | Purpose                 |
| -- | ----------------------------------- | ----------------------- |
| 01 | `01-reference-repository.png`       | Reference repository    |
| 02 | `02-all-services-running.png`       | Docker Compose services |
| 03 | `03-prometheus-targets.png`         | Prometheus targets      |
| 04 | `04-prometheus-metrics.png`         | Prometheus metrics      |
| 05 | `05-cadvisor.png`                   | cAdvisor                |
| 06 | `06-grafana-datasources.png`        | Grafana datasources     |
| 07 | `07-grafana-metrics.png`            | Grafana metrics         |
| 08 | `08-grafana-loki-logs.png`          | Loki logs               |
| 09 | `09-otel-collector-traces.png`      | OTEL traces             |
| 10 | `10-notes-app.png`                  | Notes application       |
| 11 | `11-production-overview-top.png`    | Dashboard top           |
| 11 | `11-production-overview-bottom.png` | Dashboard bottom        |

---

# 🧠 Key Learnings

Through this project I learned how the three major observability signals work together:

```text
Metrics → Prometheus → Grafana

Logs → Promtail → Loki → Grafana

Traces → OpenTelemetry Collector → Trace Backend
```

I also practiced:

* Docker Compose networking
* Docker volumes
* Prometheus scrape configuration
* PromQL
* LogQL
* Node Exporter
* cAdvisor
* Loki
* Promtail
* Grafana
* OpenTelemetry
* OTLP
* Application instrumentation
* Debugging Docker networking and port conflicts
* Building observability dashboards

The project helped me understand that observability is not only about creating dashboards. It requires a complete pipeline from **telemetry generation → collection → processing → storage → querying → visualization**.

---

# 🚀 Final Result

The Day 77 project successfully demonstrates a complete Docker-based observability environment with:

```text
✓ Infrastructure Metrics
✓ Container Metrics
✓ Application Logs
✓ OpenTelemetry Telemetry
✓ Trace Validation
✓ Grafana Visualization
✓ Docker Compose Networking
✓ Persistent Monitoring Data
✓ Application Instrumentation
```

This project provides a practical foundation for building more production-oriented observability platforms using Kubernetes, Tempo, Alertmanager, Terraform, and GitOps.

---

# 🔗 Project Repository

GitHub:

`https://github.com/Shraddha5-stack/observability-for-devops`

---

## Day 77 Status

**Completed ✅**

Built a full-stack observability environment using Docker Compose and integrated metrics, logs, traces, application telemetry, and Grafana visualization into a single monitoring project.

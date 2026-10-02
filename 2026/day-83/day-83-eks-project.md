# Day 83 — EKS Project: Production Deployment of AI-BankApp

## Overview

Deployed and validated the AI-BankApp production stack on Amazon EKS.

### Environment

- Kubernetes: Amazon EKS
- Cluster: `bankapp-eks`
- Region: `us-west-2`
- Namespace: `bankapp`
- Monitoring namespace: `monitoring`
- Container runtime: Docker
- GitOps: ArgoCD
- Infrastructure: Terraform
- CI/CD: GitHub Actions
- Container Registry: DockerHub

---

# Task 1 — Deploy Complete Stack

## Application Components

The following workloads were deployed successfully:

- BankApp
- MySQL
- Ollama

### Final workload state

```text
BankApp: 2/2 Running
MySQL:   1/1 Running
Ollama:  1/1 Running
````

### Persistent Storage

```text
mysql-pvc   Bound   5Gi   gp3
ollama-pvc  Bound   10Gi  gp3
```

MySQL data persisted successfully across pod recreation.

### Services

```text
bankapp-service   ClusterIP   8080
mysql-service     ClusterIP   3306
ollama-service    ClusterIP   11434
```

### HPA

```text
Minimum replicas: 2
Maximum replicas: 4
CPU target:       70%
Current replicas: 2
```

---

# Task 2 — Gateway API and External Access

Configured:

* Envoy Gateway
* Gateway API
* HTTPRoute
* AWS Network Load Balancer
* cert-manager
* Let's Encrypt TLS certificate
* Session affinity

### Gateway

```text
bankapp-gateway
Class: envoy-gateway
Programmed: True
```

### HTTPRoute

```text
Host: 54.200.19.53.nip.io
```

### TLS

```text
Certificate: bankapp-tls
Ready: True

ClusterIssuer: letsencrypt-prod
Ready: True
```

### Application validation

External `/login` endpoint returned:

```text
HTTP 200
```

Health endpoint returned:

```json
{"status":"UP","groups":["liveness","readiness"]}
```

---

# Task 3 — Prometheus and Grafana Monitoring

Installed `kube-prometheus-stack` using Helm.

### Monitoring configuration

```text
Namespace: monitoring
Prometheus retention: 3 days
Grafana: enabled
```

Created a ServiceMonitor for BankApp.

Metrics endpoint:

```text
/actuator/prometheus
```

Scrape interval:

```text
15s
```

Two BankApp pods were successfully discovered as Prometheus targets.

## PromQL Queries

### 1. JVM Memory

```promql
jvm_memory_used_bytes{namespace="bankapp"}
```

### 2. Request Rate

```promql
rate(http_server_requests_seconds_count{namespace="bankapp"}[5m])
```

### 3. P95 HTTP Latency

```promql
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket{namespace="bankapp"}[5m]))
```

All three queries returned valid metrics.

## Grafana Dashboard

Dashboard:

```text
AI-BankApp Production Monitoring
```

Panels created:

1. BankApp JVM Memory Usage
2. BankApp Request Rate
3. BankApp P95 HTTP Latency

---

# Task 4 — Full Validation

## Kubernetes Resources

All workloads were healthy.

```text
BankApp: 2/2
MySQL:   1/1
Ollama:  1/1
```

## Resource Metrics

```text
BankApp: ~2m CPU / 276Mi memory per pod
MySQL:   ~5m CPU / 372Mi memory
Ollama:  ~2m CPU / 109Mi memory
```

## Service Endpoints

```text
bankapp-service
10.0.5.50:8080
10.0.6.108:8080

mysql-service
10.0.6.116:3306

ollama-service
10.0.6.104:11434
```

## Deployment Validation

```text
bankapp   2/2 Available
mysql     1/1 Available
ollama    1/1 Available
```

## External Validation

```text
/login             HTTP 200
/actuator/health   status UP
```

---

# Task 5 — Reflection

## What I Learned

* How to deploy a production-style application stack on Amazon EKS.
* How Kubernetes Services provide internal communication between application components.
* How EBS-backed PersistentVolumeClaims provide persistent storage for stateful workloads.
* How Gateway API and Envoy Gateway expose applications externally.
* How cert-manager and Let's Encrypt can provide TLS certificates.
* How Horizontal Pod Autoscaler uses CPU metrics to manage application replicas.
* How Prometheus discovers and scrapes application metrics through ServiceMonitor.
* How Grafana can visualize JVM memory, request rate and HTTP latency.
* How GitOps with ArgoCD keeps the Kubernetes deployment synchronized with Git.
* How CI/CD can automatically build container images and update Kubernetes manifests.

## Challenges Faced

### Prometheus target discovery

Initially the BankApp Service did not have the label required by the ServiceMonitor.

The service was updated with:

```yaml
labels:
  app: bankapp
```

The service port was also named:

```yaml
name: http
```

After these changes, Prometheus successfully discovered both BankApp pods.

### P95 latency metrics

The request counter metrics were available, but HTTP histogram bucket metrics were initially missing.

The application was configured with:

```properties
management.metrics.distribution.percentiles-histogram.http.server.requests=true
```

After redeployment, the histogram bucket metrics became available and the P95 latency query returned valid results.

### GitOps image update

The GitOps workflow initially expected the DockerHub repository used by CI, while the Kubernetes manifest referenced the older image repository.

The workflow was corrected so that CI updates the deployment manifest with the image produced by the GitHub Actions build.

ArgoCD then synchronized the updated deployment successfully.

## Production Improvements

Possible future improvements include:

* Add centralized log aggregation with Loki.
* Add alerting rules and Alertmanager notifications.
* Add HTTPS-only redirects and stronger security headers.
* Store secrets using AWS Secrets Manager or External Secrets.
* Add network policies.
* Add PodDisruptionBudgets.
* Add resource requests and limits tuned from production usage.
* Add automated backup and restore testing for MySQL.
* Add more detailed Grafana dashboards.
* Add application-level SLOs and alerts.
* Add vulnerability scanning to the CI/CD pipeline.

---

# Final Status

The AI-BankApp production deployment was successfully deployed and validated on Amazon EKS.

```text
EKS Cluster              PASS
BankApp                   PASS
MySQL                     PASS
Ollama                    PASS
Persistent Storage        PASS
HPA                       PASS
Gateway API               PASS
External Access           PASS
TLS                       PASS
Prometheus                PASS
Grafana                   PASS
Application Metrics       PASS
P95 Latency Metrics       PASS
GitOps / ArgoCD           PASS
End-to-End Validation     PASS
```

## Conclusion

This project provided hands-on experience with deploying, exposing, monitoring and validating a production-style application on Amazon EKS using modern DevOps and GitOps practices.
EOF

```



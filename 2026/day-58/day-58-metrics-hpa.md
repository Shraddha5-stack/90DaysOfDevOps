# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)

## 📌 Overview

Today I learned how Kubernetes monitors resource usage using the **Metrics Server** and automatically adjusts the number of Pods using the **Horizontal Pod Autoscaler (HPA)**.

The practical goal was to deploy a CPU-intensive application, expose it through a Service, configure HPA, generate CPU load, and observe Kubernetes automatically scaling the application.

---

# 1. Metrics Server

## What is Metrics Server?

**Metrics Server** is a Kubernetes component that collects resource usage metrics such as:

* CPU usage
* Memory usage

It collects these metrics from the kubelets running on Kubernetes nodes.

These metrics are used by commands such as:

```bash
kubectl top nodes
kubectl top pods
```

Metrics Server is also important for the **Horizontal Pod Autoscaler**, because HPA needs current CPU or memory usage to make scaling decisions.

---

## Why does HPA need Metrics Server?

HPA needs actual resource usage to determine whether more or fewer Pods are required.

For example:

```text
CPU usage = 80%
Target CPU = 50%
```

Since the current CPU usage is higher than the target, HPA increases the number of replicas.

Without resource metrics, HPA cannot properly calculate the desired number of replicas.

---

# 2. Checking Metrics Server

I checked the resource metrics using:

```bash
kubectl top pods
```

Example output:

```text
NAME                          CPU(cores)   MEMORY(bytes)
php-apache-5899f79df5-m6n4d   1m           9Mi
```

This confirmed that Metrics Server was working.

I also used:

```bash
kubectl top pods -l run=php-apache
```

During the load test, CPU usage increased significantly.

Example:

```text
php-apache-5899f79df5-5wgzz   160m   12Mi
php-apache-5899f79df5-g2cpv   145m   11Mi
php-apache-5899f79df5-hg84z   110m   11Mi
```

---

# 3. Deployment

I created a Deployment using the Kubernetes HPA example image.

File:

```text
php-apache.yaml
```

The Deployment uses:

```yaml
image: registry.k8s.io/hpa-example
```

The container exposes port 80.

Most importantly, CPU resources were configured:

```yaml
resources:
  requests:
    cpu: 200m
  limits:
    cpu: 500m
```

## Why are CPU requests important?

HPA calculates CPU utilization as a percentage of the CPU request.

For example:

```text
CPU request = 200m
Current CPU usage = 100m
```

Then:

```text
CPU utilization = 100 / 200 × 100
                 = 50%
```

Therefore, the HPA can compare the current utilization with its target.

---

# 4. Exposing the Deployment

I exposed the Deployment using:

```bash
kubectl expose deployment php-apache --port=80
```

This created a Kubernetes Service:

```bash
kubectl get svc php-apache
```

Example:

```text
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
php-apache   ClusterIP   10.96.204.161   <none>        80/TCP
```

The Service allowed the load-generator Pod to communicate with the PHP-Apache Pods.

---

# 5. Creating HPA

I created the HPA using:

```bash
kubectl autoscale deployment php-apache \
  --cpu-percent=50 \
  --min=1 \
  --max=10
```

The command created an HPA with:

```text
Minimum replicas = 1
Maximum replicas = 10
Target CPU = 50%
```

The newer Kubernetes CLI also reports that `--cpu-percent` is deprecated and recommends:

```bash
--cpu=50%
```

---

# 6. Checking HPA

I checked the HPA using:

```bash
kubectl get hpa
```

Initially, the output showed:

```text
php-apache   Deployment/php-apache   cpu: 0%/50%   1   10   1
```

The format:

```text
current CPU / target CPU
```

means:

```text
0% / 50%
```

The application was using very little CPU at that time.

---

# 7. Generating Load

I created a temporary load-generator Pod:

```bash
kubectl run -i --tty load-generator \
  --rm \
  --image=busybox \
  --restart=Never \
  -- /bin/sh
```

Inside the Pod, I generated continuous HTTP traffic:

```bash
while true; do wget -q -O- http://php-apache; done
```

The application continuously returned:

```text
OK!
```

This generated CPU load on the PHP-Apache Pods.

---

# 8. HPA Autoscaling Under Load

I monitored the HPA using:

```bash
kubectl get hpa -w
```

During the load test, CPU utilization increased significantly.

I observed:

```text
cpu: 182%/50%
```

and later:

```text
cpu: 231%/50%
```

Because CPU utilization was significantly above the target of 50%, HPA increased the number of replicas.

The HPA scaled the application:

```text
1 replica
   ↓
4 replicas
   ↓
5 replicas
   ↓
6 replicas
   ↓
7 replicas
```

The HPA events confirmed this:

```text
SuccessfulRescale
New size: 4

SuccessfulRescale
New size: 5

SuccessfulRescale
New size: 6

SuccessfulRescale
New size: 7
```

Eventually:

```text
Deployment pods: 7 current / 7 desired
```

This confirmed that HPA was successfully working.

---

# 9. Checking the Pods

I checked the Pods using:

```bash
kubectl get pods -l run=php-apache
```

The result showed multiple running replicas:

```text
php-apache-5899f79df5-5wgzz   1/1   Running
php-apache-5899f79df5-g2cpv   1/1   Running
php-apache-5899f79df5-hg84z   1/1   Running
php-apache-5899f79df5-m6n4d   1/1   Running
php-apache-5899f79df5-nqwmk   1/1   Running
php-apache-5899f79df5-pfdfg   1/1   Running
php-apache-5899f79df5-v6wgc   1/1   Running
```

All seven Pods were running successfully.

---

# 10. HPA Calculation

HPA uses the current resource utilization and target utilization to calculate the desired number of replicas.

A simplified formula is:

```text
desiredReplicas =
ceil(currentReplicas × currentUsage / targetUsage)
```

For example:

```text
Current replicas = 2
Current CPU = 100%
Target CPU = 50%
```

Then:

```text
desiredReplicas =
ceil(2 × 100 / 50)

= ceil(4)

= 4 replicas
```

Therefore, HPA increases the number of Pods to maintain the desired CPU utilization.

---

# 11. Scale Down

When the load stopped, CPU usage dropped.

I verified the resource usage with:

```bash
kubectl top pods -l run=php-apache
```

Eventually CPU utilization became very low.

HPA also has a scale-down stabilization period.

The HPA description showed:

```text
AbleToScale: True
Reason: ScaleDownStabilized
```

The configured behavior can use a **300-second stabilization window** for scale-down.

This helps prevent Kubernetes from rapidly scaling Pods down and then immediately scaling them back up because of short-lived traffic fluctuations.

---

# 12. autoscaling/v1 vs autoscaling/v2

## autoscaling/v1

`autoscaling/v1` provides basic autoscaling functionality.

It primarily supports CPU-based autoscaling.

Example:

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
```

It is simpler but provides fewer configuration options.

---

## autoscaling/v2

`autoscaling/v2` provides more advanced HPA functionality.

Example:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
```

It supports:

* CPU metrics
* Memory metrics
* Multiple metrics
* Custom metrics
* Scale-up behavior
* Scale-down behavior
* Stabilization windows
* More detailed scaling policies

For modern Kubernetes workloads, `autoscaling/v2` is generally preferred when advanced HPA configuration is required.

---

# 13. HPA Behavior

The `behavior` section controls how quickly Kubernetes scales a workload.

Example:

```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 0

  scaleDown:
    stabilizationWindowSeconds: 300
```

## Scale Up

```yaml
scaleUp:
  stabilizationWindowSeconds: 0
```

This allows Kubernetes to respond quickly when CPU usage increases.

## Scale Down

```yaml
scaleDown:
  stabilizationWindowSeconds: 300
```

Kubernetes waits and considers recent recommendations before reducing the number of replicas.

This prevents unnecessary scaling fluctuations.

---

# 14. Important Kubernetes Commands Used

### Check Pods

```bash
kubectl get pods
```

### Check Pod details

```bash
kubectl describe pod -l run=php-apache
```

### Check resource usage

```bash
kubectl top pods
```

### Check Deployment

```bash
kubectl get deployment php-apache
```

### Expose Deployment

```bash
kubectl expose deployment php-apache --port=80
```

### Check Service

```bash
kubectl get svc php-apache
```

### Create HPA

```bash
kubectl autoscale deployment php-apache \
  --cpu-percent=50 \
  --min=1 \
  --max=10
```

### Check HPA

```bash
kubectl get hpa
```

### Detailed HPA information

```bash
kubectl describe hpa php-apache
```

### Watch HPA

```bash
kubectl get hpa -w
```

### Generate load

```bash
while true; do wget -q -O- http://php-apache; done
```

---

# 15. Practical Result

The most important result from today's practical was successful automatic scaling.

### Before Load

```text
Replicas: 1
CPU: approximately 0%
Target: 50%
```

### During Load

```text
CPU: 182%/50%
CPU: 231%/50%
```

HPA automatically increased replicas.

### Maximum Observed

```text
Replicas: 7
```

The Deployment eventually showed:

```text
7/7 READY
7 UP-TO-DATE
7 AVAILABLE
```

This demonstrated that Kubernetes can automatically increase application capacity when resource utilization becomes high.

---

# 16. Screenshots

## Metrics Server

Add a screenshot showing:

```bash
kubectl top nodes
kubectl top pods -A
```

---

## HPA

Add a screenshot showing:

```bash
kubectl get hpa
```

and:

```bash
kubectl describe hpa php-apache
```

---

## Autoscaling

Add a screenshot showing:

```bash
kubectl get hpa -w
```

with CPU utilization above the 50% target and replicas increasing.

---

## Multiple Pods

Add a screenshot showing:

```bash
kubectl get pods -l run=php-apache
```

with multiple replicas running.

---

# 17. What I Learned

Today I learned:

1. Metrics Server provides resource usage metrics to Kubernetes.
2. `kubectl top` displays actual CPU and memory usage.
3. HPA uses resource utilization to automatically change replica counts.
4. CPU requests are required for percentage-based CPU HPA calculations.
5. HPA can automatically scale Deployments.
6. A Service allows the load generator to send traffic to the application.
7. `autoscaling/v2` provides more advanced HPA features than `autoscaling/v1`.
8. HPA can control scale-up and scale-down behavior.
9. Stabilization windows help prevent unnecessary scaling fluctuations.
10. Kubernetes can automatically respond to changing application workloads.

---

# 18. Interview Questions

### Q1. What is Metrics Server?

Metrics Server is a Kubernetes component that collects CPU and memory usage metrics from nodes and Pods.

### Q2. Why does HPA need Metrics Server?

HPA needs current resource utilization metrics to decide whether to increase or decrease the number of replicas.

### Q3. What does `kubectl top` show?

It shows the current resource consumption of nodes and Pods, such as CPU and memory.

### Q4. Why are CPU requests important for HPA?

HPA calculates CPU utilization as a percentage of the Pod's CPU request. Without a CPU request, percentage-based CPU utilization cannot be calculated correctly.

### Q5. What is HPA?

HPA stands for Horizontal Pod Autoscaler. It automatically changes the number of Pods based on resource utilization or other supported metrics.

### Q6. What is the difference between horizontal and vertical scaling?

**Horizontal scaling** increases or decreases the number of Pods.

**Vertical scaling** increases or decreases the CPU or memory allocated to a Pod.

### Q7. What is the difference between `autoscaling/v1` and `autoscaling/v2`?

`autoscaling/v1` provides basic CPU-based HPA functionality, while `autoscaling/v2` supports multiple metrics and advanced scaling behavior.

### Q8. What does the HPA target `50%` mean?

It means HPA tries to maintain average CPU utilization around 50% of the CPU request.

### Q9. What happened during the load test?

CPU utilization increased above the 50% target, so HPA automatically increased the number of PHP-Apache replicas.

### Q10. How many replicas did HPA scale to?

During my test, HPA scaled the Deployment from 1 replica up to **7 replicas**.

---

# 19. Cleanup

After completing the practical, the workload resources were removed.

Commands:

```bash
kubectl delete hpa php-apache
kubectl delete service php-apache
kubectl delete deployment php-apache
kubectl delete pod load-generator
```

Metrics Server was left installed as required by the task.

---

# 🎯 Final Result

**Day 58 completed successfully.**

I installed and verified Metrics Server, used `kubectl top` to monitor resource usage, configured an HPA, generated application load, and observed Kubernetes automatically scale the application from **1 to 7 replicas**.

This practical demonstrated how Kubernetes handles variable workloads through **Horizontal Pod Autoscaling**.

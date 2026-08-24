# Day 52 – Kubernetes Namespaces and Deployments

## Overview

Today I learned and practiced Kubernetes **Namespaces** and **Deployments**.

The main goal was to understand how Kubernetes organizes resources using namespaces and how Deployments manage Pods, maintain the desired number of replicas, provide self-healing, support scaling, and perform rolling updates and rollbacks.

---

## 1. Kubernetes Namespaces

A Kubernetes Namespace provides a logical scope for resources inside a cluster.

Namespaces are useful for:

* Organizing resources
* Separating environments such as development, staging, and production
* Separating resources between teams or applications
* Managing resources within a specific scope

### Check namespaces

```bash
kubectl get namespaces
```

My cluster initially contained:

```text
default
kube-node-lease
kube-public
kube-system
local-path-storage
```

I then created two custom namespaces:

```bash
kubectl create namespace dev
kubectl create namespace staging
```

After creation:

```text
default
dev
kube-node-lease
kube-public
kube-system
local-path-storage
staging
```

---

## 2. Exploring kube-system

I checked the Pods running in the `kube-system` namespace:

```bash
kubectl get pods -n kube-system
```

There were **8 Pods** running.

Important Kubernetes components included:

* CoreDNS
* etcd
* kube-apiserver
* kube-controller-manager
* kube-scheduler
* kube-proxy
* kindnet

These components are responsible for important Kubernetes cluster functionality.

I did not modify or delete any of these system Pods.

---

## 3. Kubernetes Node

I checked the cluster node:

```bash
kubectl get nodes
```

My cluster contained one control-plane node:

```text
devops-cluster-control-plane
```

Its status was:

```text
Ready
```

The Kubernetes version shown by my cluster was:

```text
v1.37.0-rc.1
```

---

## 4. Running Pods in Different Namespaces

I created an Nginx Pod in the `dev` namespace:

```bash
kubectl run nginx-dev --image=nginx:latest -n dev
```

I also created an Nginx Pod in the `staging` namespace:

```bash
kubectl run nginx-staging --image=nginx:latest -n staging
```

I verified them using:

```bash
kubectl get pods -n dev
kubectl get pods -n staging
```

### Important observation

Running:

```bash
kubectl get pods
```

only showed Pods in the `default` namespace.

To see Pods in a specific namespace:

```bash
kubectl get pods -n dev
```

To see Pods across all namespaces:

```bash
kubectl get pods -A
```

### Namespace concept

```text
Kubernetes Cluster
│
├── default
│   ├── alpine-pod
│   ├── busybox-pod
│   ├── nginx
│   ├── nginx-pod
│   └── redis-pod
│
├── dev
│   └── nginx-dev
│
└── staging
    └── nginx-staging
```

---

# 5. Kubernetes Deployment

A Deployment manages Pods and maintains the desired number of replicas.

Unlike a standalone Pod, a Deployment can automatically create replacement Pods when Pods fail or are deleted.

The relationship is:

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

---

## 6. Deployment Manifest

I created `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
```

---

## 7. Explanation of the Deployment Manifest

### `apiVersion`

```yaml
apiVersion: apps/v1
```

Specifies the Kubernetes API version used for the Deployment.

### `kind`

```yaml
kind: Deployment
```

Defines the Kubernetes resource as a Deployment.

### `metadata`

```yaml
metadata:
  name: nginx-deployment
  namespace: dev
```

Defines the Deployment name and the namespace where it will be created.

### `replicas`

```yaml
replicas: 3
```

Tells Kubernetes that I want three identical Pods running.

### `selector`

```yaml
selector:
  matchLabels:
    app: nginx
```

The selector tells the Deployment which Pods it manages.

### Pod template

```yaml
template:
  metadata:
    labels:
      app: nginx
```

Defines the labels that will be applied to the Pods.

The selector and Pod labels must match.

### Container

```yaml
containers:
  - name: nginx
    image: nginx:1.24
```

Defines the Nginx container and the image used to create it.

### Container port

```yaml
ports:
  - containerPort: 80
```

Documents that the Nginx container listens on port 80.

---

## 8. Creating the Deployment

I applied the Deployment manifest:

```bash
kubectl apply -f nginx-deployment.yaml
```

I verified it using:

```bash
kubectl get deployments -n dev
kubectl get pods -n dev
```

The Deployment created three Pods.

The Deployment status showed:

```text
3 desired
3 updated
3 total
3 available
0 unavailable
```

This means the Deployment was healthy.

---

# 9. READY, UP-TO-DATE and AVAILABLE

### READY

Shows how many replicas are ready compared with the desired number.

For example:

```text
3/3
```

means all three desired replicas are ready.

### UP-TO-DATE

Shows how many Pods are running the current Deployment configuration.

### AVAILABLE

Shows how many replicas are available to serve the application.

For my Deployment:

```text
3 desired
3 updated
3 available
0 unavailable
```

---

# 10. Deployment and ReplicaSet

I checked the ReplicaSets:

```bash
kubectl get replicasets -n dev
```

The Deployment automatically created a ReplicaSet.

The relationship is:

```text
Deployment
nginx-deployment
       │
       ▼
ReplicaSet
nginx-deployment-7f5f95d8d
       │
       ├── Pod
       ├── Pod
       └── Pod
```

The ReplicaSet is responsible for maintaining the desired number of Pods.

---

# 11. Self-Healing

I tested Kubernetes self-healing by deleting one of the Pods managed by the Deployment.

I deleted:

```bash
kubectl delete pod nginx-deployment-7f5f95d8d-n4skm -n dev
```

The deleted Pod disappeared.

Kubernetes immediately created a replacement Pod:

```text
nginx-deployment-7f5f95d8d-zdntd
```

The replacement Pod had a different name.

### What happened?

Initially:

```text
Desired = 3
Current = 3
```

After deleting a Pod:

```text
Desired = 3
Current = 2
```

The ReplicaSet detected the difference and created a new Pod.

Final state:

```text
Desired = 3
Current = 3
```

### Important learning

A Deployment does not restore the exact deleted Pod.

Instead, Kubernetes creates a **new Pod** to maintain the desired state.

---

# 12. Scaling the Deployment

I practiced scaling the Deployment.

### Scaling down

I changed the Deployment to two replicas:

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n dev
```

Kubernetes terminated one Deployment-managed Pod.

The final state contained:

```text
2 Deployment-managed Pods
1 standalone nginx-dev Pod
```

The standalone `nginx-dev` Pod was not affected because it was not managed by the Deployment.

### Scaling concept

If:

```text
Desired = 5
```

Kubernetes creates Pods until five replicas are running.

If:

```text
Desired = 2
```

Kubernetes terminates extra Pods until only two Deployment-managed Pods remain.

---

# 13. Imperative vs Declarative Scaling

I used an imperative command:

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n dev
```

This directly changes the live resource.

My YAML originally contained:

```yaml
replicas: 3
```

Therefore, if I apply the original YAML again:

```bash
kubectl apply -f nginx-deployment.yaml
```

Kubernetes can change the desired replica count back to three because the manifest declares:

```yaml
replicas: 3
```

This demonstrates the difference between imperative commands and declarative configuration.

---

# 14. Rolling Update

The original Deployment used:

```text
nginx:1.24
```

I performed a rolling update using:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

I then checked the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

The rollout completed successfully.

---

## 15. New ReplicaSet During Rolling Update

After updating the image, Kubernetes created a new ReplicaSet:

```text
nginx-deployment-6946987795
```

The old ReplicaSet was:

```text
nginx-deployment-7f5f95d8d
```

The final ReplicaSet status showed:

```text
nginx-deployment-6946987795   2   2   2
nginx-deployment-7f5f95d8d    0   0   0
```

This demonstrated that Kubernetes had moved the application from the old ReplicaSet to the new ReplicaSet.

Conceptually:

```text
Old ReplicaSet
nginx:1.24
      ↓
Rolling Update
      ↓
New ReplicaSet
nginx:1.25
```

---

# 16. Rollout History

I checked the Deployment history:

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

The output showed:

```text
REVISION
1
2
```

Revision 1 represented the original Deployment configuration.

Revision 2 represented the updated configuration using `nginx:1.25`.

---

# 17. Rollback

After testing the new version, I performed a rollback:

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

I verified the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Finally, I checked the running image:

```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

The result was:

```text
nginx:1.24
```

Therefore, the rollback was successful.

The complete process was:

```text
nginx:1.24
    ↓
Rolling Update
    ↓
nginx:1.25
    ↓
Rollback
    ↓
nginx:1.24
```

---

# 18. Important Commands Learned

### Namespaces

```bash
kubectl get namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -A
```

### Deployments

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get deployments -n dev
kubectl describe deployment nginx-deployment -n dev
```

### ReplicaSets

```bash
kubectl get replicasets -n dev
```

### Scaling

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl scale deployment nginx-deployment --replicas=2 -n dev
```

### Rolling updates

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
kubectl rollout status deployment/nginx-deployment -n dev
kubectl rollout history deployment/nginx-deployment -n dev
```

### Rollback

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

---

# 19. Standalone Pod vs Deployment

| Standalone Pod                           | Deployment                             |
| ---------------------------------------- | -------------------------------------- |
| Runs a Pod directly                      | Manages application Pods               |
| No automatic replacement by a Deployment | Automatically maintains replicas       |
| Difficult to scale                       | Easy to scale                          |
| No Deployment rollout mechanism          | Supports rolling updates               |
| No Deployment rollback                   | Supports rollbacks                     |
| Suitable for simple testing              | Commonly used for running applications |

The key difference I learned:

```text
Standalone Pod
    ↓
Delete Pod
    ↓
Gone
```

Whereas:

```text
Deployment
    ↓
Delete Pod
    ↓
ReplicaSet detects missing replica
    ↓
New Pod created
```

---

# 20. Screenshots

The following screenshots were captured during the practical:

1. `01-namespaces.png` — Kubernetes namespaces
2. `02-pods-all-namespaces.png` — Pods across namespaces
3. `03-deployment.png` — Deployment status
4. `04-deployment-pods.png` — Deployment Pods
5. `05-replicasets.png` — ReplicaSets
6. `06-rollout-history.png` — Deployment rollout history
7. `07-rollback-image.png` — Verification of `nginx:1.24` after rollback

---

# 21. Key Takeaways

Today I learned:

* Namespaces organize Kubernetes resources.
* `kubectl get pods` shows Pods in the current/default namespace.
* `kubectl get pods -n <namespace>` targets a specific namespace.
* `kubectl get pods -A` shows Pods across all namespaces.
* Deployments manage application Pods.
* Deployments use ReplicaSets to maintain the desired number of Pods.
* Deployments provide self-healing when managed Pods are deleted.
* Deployments can be scaled up and down.
* `kubectl set image` can trigger a rolling update.
* Rolling updates create a new ReplicaSet.
* Old ReplicaSets can remain for rollout history and rollback.
* `kubectl rollout undo` can return an application to a previous revision.
* The desired state is an important Kubernetes concept.

---

# Conclusion

Day 52 helped me move from running standalone Kubernetes Pods to managing applications with Deployments.

I created and used multiple namespaces, deployed Nginx with multiple replicas, tested self-healing by deleting a Pod, scaled the Deployment, performed a rolling update from Nginx 1.24 to 1.25, and successfully rolled back to Nginx 1.24.

The most important concept I learned is:

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Container
```

Kubernetes continuously works to make the actual state match the desired state.

**Day 52 completed successfully. 🚀**

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham

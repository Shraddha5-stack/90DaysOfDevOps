# Day 78 – Introduction to Helm and Chart Basics

## Objective

Learn Helm, understand Helm chart structure, and deploy Kubernetes applications using public Helm charts.

Helm is a package manager for Kubernetes. It allows Kubernetes applications to be packaged, configured, installed, upgraded, rolled back, and uninstalled using reusable charts.

---

## Environment

* Kubernetes cluster: `devops-cluster`
* Kubernetes namespace: `capstone`
* Kubernetes context: `kind-devops-cluster`
* Helm: Installed and working
* Helm repository: Bitnami

---

## 1. Helm Installation and Verification

Verified that Helm is installed:

```bash
helm version
```

Verified Kubernetes connectivity:

```bash
kubectl get nodes
```

The Kubernetes node was in `Ready` state.

---

## 2. Add Public Helm Repository

Added the Bitnami public Helm repository:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Searched for available NGINX charts:

```bash
helm search repo bitnami/nginx
```

Example result:

```text
bitnami/nginx
bitnami/nginx-ingress-controller
bitnami/nginx-intel
```

---

## 3. Helm Chart Structure

A Helm chart commonly contains:

```text
my-chart/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
└── .helmignore
```

### Chart.yaml

`Chart.yaml` contains chart metadata such as:

* Chart name
* Chart version
* Application version
* Description
* Dependencies
* Maintainers

For the Bitnami NGINX chart:

```yaml
apiVersion: v2
name: nginx
version: 25.1.15
appVersion: 1.31.6
```

### Important Difference

**Chart version** and **application version** are different.

```text
Chart Version    → 25.1.15
Application      → NGINX 1.31.6
```

The chart version identifies the Helm chart package, while the application version identifies the software being deployed.

### values.yaml

`values.yaml` contains configurable values used by the templates.

Example:

```yaml
replicaCount: 1
```

### templates/

The `templates/` directory contains Kubernetes resource templates.

Helm expressions such as:

```text
.Values.replicaCount
```

allow values from `values.yaml` to be inserted into Kubernetes manifests.

### Helm Template Flow

```text
values.yaml
     ↓
.Values.replicaCount
     ↓
templates/deployment.yaml
     ↓
helm template
     ↓
Rendered Kubernetes YAML
```

---

## 4. Inspecting the NGINX Chart

Displayed chart metadata:

```bash
helm show chart bitnami/nginx
```

The chart showed:

```yaml
apiVersion: v2
name: nginx
version: 25.1.15
appVersion: 1.31.6
```

Displayed chart values:

```bash
helm show values bitnami/nginx
```

Downloaded the chart locally for inspection:

```bash
helm pull bitnami/nginx --untar -d /tmp
```

The chart structure was:

```text
/tmp/nginx/
├── Chart.yaml
├── values.yaml
├── README.md
├── charts/
├── templates/
└── .helmignore
```

Inspected the deployment template:

```bash
grep -n "\.Values" /tmp/nginx/templates/deployment.yaml | head -20
```

This demonstrated how Helm values are used inside Kubernetes templates.

---

## 5. Helm Template

Rendered the NGINX chart without installing it:

```bash
helm template day78-nginx bitnami/nginx -n capstone > /tmp/day78-nginx-rendered.yaml
```

This generated the Kubernetes manifests that Helm would apply to the cluster.

### Important Concept

```bash
helm template
```

renders the Kubernetes manifests locally but does not install the Helm release.

---

# 6. Deploy MySQL Using Helm

Deployed MySQL using the Bitnami MySQL Helm chart.

Release name:

```text
bankapp-mysql
```

Namespace:

```text
capstone
```

The MySQL release was configured with:

```text
image.repository=bitnamilegacy/mysql
image.tag=9.4.0-debian-12-r1
auth.database=bankappdb
primary.persistence.size=5Gi
```

The release was successfully deployed.

Verified the Helm release:

```bash
helm list -n capstone
```

Result included:

```text
bankapp-mysql   capstone   2   deployed   mysql-14.0.3   9.4.0
```

Verified the MySQL service:

```bash
kubectl get svc -n capstone | grep bankapp
```

Services:

```text
bankapp-mysql
bankapp-mysql-headless
```

Verified persistent storage:

```bash
kubectl get pvc -n capstone | grep bankapp
```

The MySQL PVC was:

```text
Bound
5Gi
RWO
```

---

# 7. Deploy NGINX Using Helm

Installed NGINX from the public Bitnami repository:

```bash
helm install day78-nginx bitnami/nginx -n capstone
```

Release name:

```text
day78-nginx
```

The initial deployment used one replica.

Verified the NGINX pod:

```bash
kubectl get pods -n capstone -l app.kubernetes.io/instance=day78-nginx
```

The pod reached:

```text
1/1 Running
```

---

# 8. Helm Upgrade

Changed the NGINX replica count from 1 to 2:

```bash
helm upgrade day78-nginx bitnami/nginx \
  -n capstone \
  --set replicaCount=2
```

Helm created Revision 2.

Verified:

```bash
helm list -n capstone
```

The release showed:

```text
day78-nginx   capstone   2   deployed   nginx-25.1.15   1.31.6
```

Verified the deployment:

```bash
kubectl get deployment day78-nginx -n capstone
```

Result:

```text
READY   UP-TO-DATE   AVAILABLE
2/2     2            2
```

Two NGINX pods were running.

---

# 9. Helm History

Checked the release history:

```bash
helm history day78-nginx -n capstone
```

The history showed:

```text
REVISION   STATUS
1          superseded
2          deployed
```

Revision 1 represented the original installation.

Revision 2 represented the upgrade to two replicas.

---

# 10. Helm Rollback

Rolled the NGINX release back to Revision 1:

```bash
helm rollback day78-nginx 1 -n capstone
```

Rollback was successful.

Helm created Revision 3.

Verified:

```bash
helm history day78-nginx -n capstone
```

Result:

```text
1   superseded   Install complete
2   superseded   Upgrade complete
3   deployed     Rollback to 1
```

Verified the deployment:

```bash
kubectl get deployment day78-nginx -n capstone
```

Result:

```text
READY   UP-TO-DATE   AVAILABLE
1/1     1            1
```

The NGINX replica count returned to 1.

### Important Concept

Rollback does not change Revision 3 back into Revision 1.

Instead:

```text
Revision 1 → Install
      ↓
Revision 2 → Upgrade to 2 replicas
      ↓
Revision 3 → Rollback to Revision 1 configuration
```

Helm preserves the release history.

---

# 11. Helm Uninstall

Created a temporary NGINX release to safely practice uninstall:

```bash
helm install day78-test bitnami/nginx -n capstone
```

Verified the release:

```bash
helm list -n capstone
```

Then removed only the temporary test release:

```bash
helm uninstall day78-test -n capstone
```

Output:

```text
release "day78-test" uninstalled
```

Verified:

```bash
helm list -n capstone
```

The remaining Helm releases were:

```text
bankapp-mysql
day78-nginx
```

This demonstrated that `helm uninstall` removes the Kubernetes resources belonging to that Helm release.

---

# 12. Final Helm Release Status

Final Helm release status:

```bash
helm list -n capstone
```

Result:

```text
NAME            NAMESPACE   REVISION   STATUS
bankapp-mysql   capstone    2          deployed
day78-nginx     capstone    3          deployed
```

---

# 13. Final Kubernetes Verification

Verified the workloads:

```bash
kubectl get pods -n capstone
```

Important Helm-managed workloads were running:

```text
bankapp-mysql-0
day78-nginx-685d848bdf-qxwpf
```

Both were in:

```text
1/1 Running
```

The temporary `day78-test` workload was successfully removed.

---

# 14. Troubleshooting

## Bitnami MySQL Image Issue

The MySQL deployment initially encountered an image availability problem with:

```text
docker.io/bitnami/mysql:9.4.0-debian-12-r1
```

The Helm configuration was adjusted to use:

```text
bitnamilegacy/mysql:9.4.0-debian-12-r1
```

The release was upgraded using:

```text
global.security.allowInsecureImages=true
image.repository=bitnamilegacy/mysql
image.tag=9.4.0-debian-12-r1
```

The MySQL pod then successfully reached:

```text
1/1 Running
```

## Docker Context Issue

The Kind cluster was associated with the `default` Docker context.

Selected the correct Docker context:

```bash
docker context use default
```

Verified the Kind cluster:

```bash
kind get clusters
```

Result:

```text
devops-cluster
```

The cluster became available for image loading and Kubernetes operations.

---

# 15. Important Helm Commands Learned

| Command            | Purpose                       |
| ------------------ | ----------------------------- |
| `helm repo add`    | Add a Helm chart repository   |
| `helm repo update` | Update repository information |
| `helm search repo` | Search available charts       |
| `helm show chart`  | Display chart metadata        |
| `helm show values` | Display configurable values   |
| `helm pull`        | Download a chart              |
| `helm template`    | Render chart templates        |
| `helm install`     | Install a Helm release        |
| `helm list`        | List Helm releases            |
| `helm upgrade`     | Upgrade an existing release   |
| `helm history`     | View release history          |
| `helm rollback`    | Roll back a release           |
| `helm uninstall`   | Remove a Helm release         |

---

# 16. What I Learned

* Helm is a package manager for Kubernetes.
* A Helm chart packages Kubernetes application resources.
* `Chart.yaml` contains chart metadata.
* `values.yaml` contains configurable values.
* `templates/` contains Kubernetes resource templates.
* `.Values` connects values to templates.
* `helm template` renders manifests without installing them.
* Helm releases have revisions.
* `helm install` creates a release.
* `helm upgrade` creates a new revision.
* `helm rollback` restores a previous configuration and creates a new revision.
* `helm uninstall` removes a Helm release.
* Public repositories such as Bitnami provide reusable Kubernetes charts.

---

# 17. Day 78 Completion Checklist

* [x] Helm installed
* [x] Helm connected to Kubernetes
* [x] Public Helm repository added
* [x] MySQL deployed using Helm
* [x] NGINX deployed using Helm
* [x] Chart structure understood
* [x] `Chart.yaml` inspected
* [x] `values.yaml` inspected
* [x] `templates/` inspected
* [x] `helm template` practiced
* [x] Helm install practiced
* [x] Helm upgrade practiced
* [x] Helm rollback practiced
* [x] Helm uninstall practiced
* [x] Release history verified
* [x] Kubernetes resources verified

## Conclusion

Day 78 provided hands-on experience with Helm and Kubernetes application lifecycle management.

I deployed applications using public Helm charts and practiced:

```text
Install
   ↓
Configure
   ↓
Upgrade
   ↓
Rollback
   ↓
Uninstall
```

This helped me understand how Helm simplifies Kubernetes application deployment and lifecycle management.

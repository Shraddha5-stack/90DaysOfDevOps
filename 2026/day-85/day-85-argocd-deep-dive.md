# Day 85 — ArgoCD Deep Dive

## Overview

Today I performed an advanced ArgoCD GitOps deep dive using the AI-BankApp EKS project.

The focus was on:

* Manual vs Automated Sync
* ArgoCD Sync Waves
* Application Rollback
* App of Apps
* ArgoCD Notifications
* ArgoCD Projects and RBAC

The work was performed on an Amazon EKS cluster running the AI-BankApp application.

## Environment

| Component             | Details                             |
| --------------------- | ----------------------------------- |
| Cloud                 | AWS                                 |
| Kubernetes            | Amazon EKS                          |
| Cluster               | `bankapp-eks`                       |
| Region                | `us-west-2`                         |
| ArgoCD                | `v3.5.3`                            |
| ArgoCD Helm Chart     | `argo-cd-10.9.6`                    |
| GitOps Repository     | `Shraddha5-stack/AI-BankApp-DevOps` |
| Git Branch            | `feat/gitops`                       |
| Application           | `bankapp`                           |
| Application Namespace | `bankapp`                           |
| ArgoCD Namespace      | `argocd`                            |

## Learning Objectives

By completing this task, I learned how to:

1. Switch between automated and manual ArgoCD synchronization.
2. Detect Git changes using `OutOfSync` status.
3. Compare desired and live state using `argocd app diff`.
4. Perform dry-run and manual synchronization.
5. Control deployment order using sync waves.
6. Roll back an ArgoCD application to a previous revision.
7. Use the App of Apps pattern to manage multiple ArgoCD Applications.
8. Configure ArgoCD Notifications using templates and triggers.
9. Create an ArgoCD AppProject with repository and destination restrictions.
10. Configure read-only ArgoCD RBAC.

---

# Task 1 — Manual vs Automated Sync

## Objective

The objective was to understand the difference between ArgoCD automated synchronization and manual synchronization.

With automated sync enabled, ArgoCD continuously reconciles the Kubernetes cluster with the Git repository.

With automated sync disabled, ArgoCD detects changes but does not automatically apply them to the cluster.

## 1. Disable Automated Sync

I disabled automated synchronization for the `bankapp` Application:

```bash
kubectl patch application bankapp -n argocd \
  --type=json \
  -p='[{"op":"remove","path":"/spec/syncPolicy/automated"}]'
```

I then performed a hard refresh:

```bash
kubectl annotate application bankapp -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
```

## 2. Create a Git Change

I initially tested a harmless Git comment change. The comment did not cause `OutOfSync` because comments do not change the rendered Kubernetes manifest.

This demonstrated that ArgoCD compares the rendered desired Kubernetes state with the live Kubernetes state rather than simply comparing Git commit history.

I then made a real ConfigMap change:

```yaml
DAY85_MANUAL_SYNC_TEST: "true"
```

The change was committed and pushed with commit:

```text
8244522 test: trigger manual ArgoCD sync
```

## 3. Verify OutOfSync

After refreshing ArgoCD, the application showed:

```text
OutOfSync
Revision: 8244522
```

The live ConfigMap initially did not contain the new key.

This proved that automated synchronization was disabled.

The desired state existed in Git, but ArgoCD did not automatically apply it to Kubernetes.

## 4. Compare Desired and Live State

I used:

```bash
argocd app diff bankapp
```

ArgoCD displayed the difference between the desired Git state and the live Kubernetes state.

The important difference was:

```yaml
DAY85_MANUAL_SYNC_TEST: "true"
```

## 5. Perform a Sync Dry Run

I performed a synchronization dry run:

```bash
argocd app sync bankapp --dry-run
```

The dry run completed successfully.

This allowed me to verify the synchronization without changing the cluster.

## 6. Perform the Real Manual Sync

I then manually synchronized the application:

```bash
argocd app sync bankapp
```

The synchronization succeeded.

I verified that the new ConfigMap value was present in the cluster.

## 7. Re-enable Automated Sync

After completing the manual synchronization test, I restored automated synchronization:

```bash
kubectl -n argocd patch application bankapp \
  --type merge \
  -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

I verified the configuration:

```bash
kubectl get application bankapp -n argocd \
  -o jsonpath='{.spec.syncPolicy.automated}' && echo
```

Result:

```text
{"prune":true,"selfHeal":true}
```

## Result

The complete manual synchronization workflow was demonstrated:

```text
Git change
    ↓
ArgoCD detects change
    ↓
Automated sync disabled
    ↓
Application becomes OutOfSync
    ↓
argocd app diff
    ↓
argocd app sync --dry-run
    ↓
argocd app sync
    ↓
Kubernetes updated
    ↓
Automated sync restored
```

## Interview Explanation

**Question: What is the difference between manual and automated sync in ArgoCD?**

**Answer:**

> In manual sync, ArgoCD detects that the Git desired state differs from the Kubernetes live state, but it waits for an operator to trigger synchronization. In automated sync, ArgoCD automatically reconciles the cluster with Git. Automated sync is useful for continuous GitOps deployments, while manual sync provides additional control when changes need to be reviewed before being applied.

---

# Task 2 — ArgoCD Sync Waves

## Objective

Sync waves were used to control the order in which Kubernetes resources are synchronized.

The following deployment order was implemented:

```text
Wave -2
  Namespace
  StorageClass

Wave -1
  PVC
  ConfigMap
  Secret

Wave 0
  MySQL Deployment
  Ollama Deployment
  Services

Wave 1
  BankApp Deployment

Wave 2
  HPA
```

Resources that were not explicitly assigned a wave, such as the existing Gateway and cert-manager manifests, remained on the default wave.

## Sync Wave Configuration

### Wave -2

The Namespace was configured with:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-2"
```

The StorageClass manifest was also assigned wave `-2`.

### Wave -1

The PVC resources were assigned:

```yaml
argocd.argoproj.io/sync-wave: "-1"
```

The ConfigMap was also assigned wave `-1`.

The Secret was assigned wave `-1`.

The existing:

```yaml
DAY85_MANUAL_SYNC_TEST: "true"
```

configuration was preserved.

### Wave 0

The MySQL Deployment was assigned wave `0`.

The Ollama Deployment was assigned wave `0`.

The Kubernetes Services were assigned wave `0`.

### Wave 1

The BankApp Deployment was assigned:

```yaml
argocd.argoproj.io/sync-wave: "1"
```

The existing Day 84 GitOps test annotation was preserved:

```yaml
gitops-test: "day-84"
```

### Wave 2

The HorizontalPodAutoscaler was assigned:

```yaml
argocd.argoproj.io/sync-wave: "2"
```

## Validation

The manifests were checked for the required annotations and duplicate annotations.

I also ran:

```bash
git diff --check
```

The command produced no output, confirming that there were no whitespace errors.

The sync-wave configuration was committed as:

```text
eed84ad feat: add ArgoCD sync waves
```

and pushed to:

```text
feat/gitops
```

## Result

The final intended synchronization order was:

```text
-2 → -1 → 0 → 1 → 2
```

This provides deterministic deployment ordering and helps ensure that dependencies are created before resources that depend on them.

## Interview Explanation

**Question: What are ArgoCD sync waves?**

**Answer:**

> Sync waves allow us to control the order in which ArgoCD applies resources. Resources with lower wave numbers are synchronized before resources with higher wave numbers. For example, I used negative waves for foundational resources such as Namespace and storage configuration, wave 0 for infrastructure workloads, wave 1 for the application Deployment, and wave 2 for the HPA.

---

# Task 3 — ArgoCD Rollback

## Objective

The objective was to understand how ArgoCD keeps application history and how a previous application state can be restored.

## 1. Check Application History

I checked the ArgoCD application history.

The history contained:

```text
ID   DATE                         REVISION
0    2026-10-03 22:54:18 +0530   66dcce1
1    2026-10-03 23:16:42 +0530   9e1aaae
2    2026-10-04 08:52:55 +0530   8244522
```

The latest Git revision at the end of the sync-wave work was:

```text
eed84ad
```

## 2. Test Rollback With Automated Sync Enabled

I attempted:

```bash
argocd app rollback bankapp 2
```

while automated synchronization was enabled.

ArgoCD rejected the rollback because rollback cannot be initiated while automated sync is enabled.

This demonstrated that automated synchronization must be disabled before using the ArgoCD rollback operation.

## 3. Disable Automated Sync

Automated synchronization was disabled for the rollback test.

## 4. Roll Back

I rolled the application back to revision `1`:

```bash
argocd app rollback bankapp 1
```

The rollback succeeded.

The application was then using the older revision:

```text
9e1aaae
```

while the latest Git revision was:

```text
eed84ad
```

Therefore the application became `OutOfSync`.

## 5. Restore the Latest Git State

A full synchronization initially encountered an issue with the existing Gateway/TLS resource.

The BankApp Deployment and HPA were therefore synchronized explicitly:

```bash
argocd app sync bankapp \
  --resource apps:Deployment:bankapp/bankapp \
  --resource autoscaling:HorizontalPodAutoscaler:bankapp/bankapp-hpa
```

The Deployment and HPA synchronized successfully.

The overall application returned to the latest Git revision:

```text
eed84ad
```

## 6. Re-enable Automated Sync

Automated synchronization was restored:

```bash
kubectl -n argocd patch application bankapp \
  --type merge \
  -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

## Rollback vs Git Revert

ArgoCD rollback is useful for quickly restoring an application to an earlier ArgoCD revision.

However, Git remains the source of truth in GitOps.

For a permanent rollback in a GitOps workflow, a better approach is usually:

```text
git revert
    ↓
Push change to Git
    ↓
ArgoCD detects Git change
    ↓
ArgoCD reconciles Kubernetes
```

Therefore:

* **ArgoCD rollback** → operational rollback
* **Git revert** → GitOps source-of-truth rollback

## Interview Explanation

> ArgoCD rollback allows an application to be restored to a previous ArgoCD revision. However, because Git is the source of truth in GitOps, a permanent rollback should generally be represented in Git using `git revert`, allowing ArgoCD to reconcile the cluster to that state.

---

# Task 4 — App of Apps

## Objective

The App of Apps pattern allows one parent ArgoCD Application to manage multiple child Applications.

The final structure created was:

```text
argocd/
├── root-application.yml
└── app-of-apps/
    ├── bankapp-application.yml
    ├── monitoring-application.yml
    └── envoy-application.yml
```

## 1. BankApp Child Application

The BankApp child Application points to:

```text
https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git
```

Branch:

```text
feat/gitops
```

Path:

```text
k8s
```

It deploys into:

```text
bankapp
```

Automated synchronization is enabled with:

```yaml
automated:
  prune: true
  selfHeal: true
```

## 2. Monitoring Child Application

A lightweight demonstration Application was created for monitoring.

Source path:

```text
app-of-apps-resources/monitoring
```

The child Application deploys into the `argocd` namespace.

A lightweight ConfigMap was used instead of installing another Prometheus/Grafana stack.

## 3. Envoy Child Application

A lightweight Envoy demonstration Application was created.

Source path:

```text
app-of-apps-resources/envoy
```

A ConfigMap was used to demonstrate the App of Apps pattern without installing duplicate infrastructure.

## 4. Root Application

The root Application was created at:

```text
argocd/root-application.yml
```

The root points to:

```text
argocd/app-of-apps
```

with recursive directory processing enabled.

The root Application was intentionally kept outside the child Application directory to avoid the parent discovering itself as a child.

## 5. Validate Child Applications

All three child manifests were validated:

```bash
kubectl apply --dry-run=client -f argocd/app-of-apps/
```

Result:

```text
application.argoproj.io/bankapp configured (dry run)
application.argoproj.io/envoy created (dry run)
application.argoproj.io/monitoring created (dry run)
```

The root Application was also validated:

```bash
kubectl apply --dry-run=client -f argocd/root-application.yml
```

Result:

```text
application.argoproj.io/bankapp-root created (dry run)
```

## 6. Create Root Application

The root Application was created:

```bash
kubectl apply -f argocd/root-application.yml
```

Result:

```text
application.argoproj.io/bankapp-root created
```

## 7. Verify App of Apps

I checked the ArgoCD Applications:

```bash
kubectl get applications -n argocd
```

Result:

```text
NAME           SYNC STATUS   HEALTH STATUS
bankapp        Synced        Degraded
bankapp-root   Synced        Healthy
envoy          Synced        Healthy
monitoring     Synced        Healthy
```

The root Application was healthy and successfully managed the child Applications.

The existing `bankapp` Application remained `Degraded` because of its existing Gateway/TLS health issue; this was separate from the App of Apps implementation.

## 8. Verify Child Resources

I verified that the child Applications actually created their resources:

```bash
kubectl get configmap -n argocd \
  argocd-monitoring-demo \
  argocd-envoy-demo
```

Result:

```text
NAME                     DATA   AGE
argocd-monitoring-demo   2      41s
argocd-envoy-demo        2      41s
```

## App of Apps Architecture

```text
                    Git Repository
                         │
                         ▼
                  bankapp-root
                    /    |    \
                   /     |     \
                  ▼      ▼      ▼
             bankapp  monitoring envoy
                          │        │
                          ▼        ▼
                    monitoring   envoy
                     ConfigMap   ConfigMap
```

## Interview Explanation

> The App of Apps pattern uses a parent ArgoCD Application to manage multiple child Applications. The parent points to a Git directory containing Application manifests. This provides a scalable way to organize multiple applications while keeping their desired state declarative and version-controlled in Git.

---

# Task 5 — ArgoCD Notifications

## Objective

The objective was to configure ArgoCD Notifications using:

* Notification Controller
* Notification template
* Notification trigger
* Notification Secret

## 1. Notification Configuration

I created:

```text
argocd/notifications/
```

with:

```text
notifications-cm.yml
notifications-secret.yml
```

The ConfigMap was configured with:

```yaml
context:
  argocdUrl: https://argocd.example.com
```

A sync-status notification template was configured:

```yaml
template.app-sync-status
```

The template includes the Application name, sync status, and health status.

A trigger was configured:

```yaml
trigger.on-sync-status
```

The trigger sends the `app-sync-status` notification when the Application sync status is not `Unknown`.

## 2. Validate Notification ConfigMap

I validated the manifest:

```bash
kubectl apply --dry-run=client \
  -f argocd/notifications/notifications-cm.yml
```

Result:

```text
configmap/argocd-notifications-cm configured (dry run)
```

## 3. Apply Notifications Configuration

I applied:

```bash
kubectl apply -f argocd/notifications/
```

The ConfigMap and Secret were configured successfully.

The Kubernetes warnings about the missing `kubectl.kubernetes.io/last-applied-configuration` annotation were informational. Kubernetes patched the annotation automatically.

## 4. Verify Notification Resources

I checked the ConfigMap:

```bash
kubectl get configmap argocd-notifications-cm -n argocd
```

Result:

```text
NAME                      DATA   AGE
argocd-notifications-cm   3      11h
```

The Secret was also present:

```text
NAME                          TYPE     DATA   AGE
argocd-notifications-secret   Opaque   0      11h
```

## 5. Verify Notification Controller

I checked:

```bash
kubectl get deployment -n argocd | grep notifications
```

Result:

```text
argocd-notifications-controller    1/1     1     1     11h
```

The Notifications Controller was already installed as part of the ArgoCD installation.

## 6. Verify Controller Logs

I checked:

```bash
kubectl logs deployment/argocd-notifications-controller \
  -n argocd --tail=30
```

The logs showed successful processing of:

```text
bankapp
bankapp-root
monitoring
envoy
```

The controller also detected changes to:

```text
argocd-notifications-cm
argocd-notifications-secret
```

through cache invalidation messages.

## Important Note

The notification configuration contains an email template, but an SMTP/email delivery service was not configured.

Therefore, this task demonstrates the Notification Controller, template, and trigger configuration, but does not claim that an actual email was delivered.

## Notification Architecture

```text
ArgoCD Application Event
          │
          ▼
       Trigger
          │
          ▼
     Notification
       Template
          │
          ▼
   Delivery Service
   (Email / Slack / etc.)
```

## Interview Explanation

> ArgoCD Notifications monitors Application events and uses triggers to decide when a notification should be sent. Templates define the notification content, while services such as email or Slack provide the delivery mechanism.

---

# Task 6 — ArgoCD Projects and RBAC

## Objective

The objective was to understand how ArgoCD Projects restrict application sources, destinations, and resources, and how RBAC controls user/group permissions.

## 1. Create an AppProject

I created:

```text
argocd/projects/bankapp-project.yml
```

The project was named:

```text
bankapp-project
```

The allowed Git repository was restricted to:

```text
https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git
```

The allowed destinations were:

```text
bankapp
argocd
```

The project allows the Namespace cluster resource and namespace resources.

## 2. Validate the Project

I validated the manifest:

```bash
kubectl apply --dry-run=client \
  -f argocd/projects/bankapp-project.yml
```

Result:

```text
appproject.argoproj.io/bankapp-project created (dry run)
```

## 3. Create the Project

I applied:

```bash
kubectl apply -f argocd/projects/bankapp-project.yml
```

Result:

```text
appproject.argoproj.io/bankapp-project created
```

I verified it:

```bash
kubectl get appproject bankapp-project -n argocd
```

Result:

```text
NAME              AGE
bankapp-project   3s
```

## 4. Verify Project Repository

I checked the configured source repository:

```bash
kubectl get appproject bankapp-project -n argocd -o yaml \
  | sed -n '/sourceRepos:/,/namespaceResourceWhitelist:/p'
```

The configured repository was:

```text
https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git
```

## 5. Verify Project Destinations

I checked:

```bash
kubectl get appproject bankapp-project -n argocd \
  -o jsonpath='{.spec.destinations[*].namespace}'; echo
```

Result:

```text
bankapp argocd
```

## 6. Inspect Existing RBAC Configuration

The existing RBAC ConfigMap initially contained:

```yaml
policy.csv: ""
policy.default: ""
policy.matchMode: glob
scopes: '[groups]'
```

## 7. Configure Read-Only RBAC

I created a read-only role:

```text
bankapp-readonly
```

and mapped the group:

```text
devops-readonly
```

The policy was:

```text
p, role:bankapp-readonly, applications, get, bankapp-project/*, allow
g, devops-readonly, role:bankapp-readonly
```

The policy was added using:

```bash
kubectl patch configmap argocd-rbac-cm -n argocd \
  --type merge \
  -p '{"data":{"policy.csv":"p, role:bankapp-readonly, applications, get, bankapp-project/*, allow\ng, devops-readonly, role:bankapp-readonly\n"}}'
```

## 8. Verify RBAC Policy

I verified the complete policy:

```bash
kubectl get configmap argocd-rbac-cm -n argocd -o yaml \
  | sed -n '/policy.csv:/,/^[^ ]/p'
```

Result:

```text
policy.csv: |
  p, role:bankapp-readonly, applications, get, bankapp-project/*, allow
  g, devops-readonly, role:bankapp-readonly
```

## 9. Reload ArgoCD Server

I restarted the ArgoCD server so the RBAC configuration was reloaded:

```bash
kubectl rollout restart deployment argocd-server -n argocd \
  && kubectl rollout status deployment argocd-server -n argocd --timeout=120s
```

Result:

```text
deployment.apps/argocd-server restarted
deployment "argocd-server" successfully rolled out
```

## 10. Verify ArgoCD Server Health

I checked the server pod:

```bash
kubectl get pods -n argocd \
  -l app.kubernetes.io/name=argocd-server
```

Result:

```text
NAME                             READY   STATUS    RESTARTS   AGE
argocd-server-6f57ddf54d-qh8js   1/1     Running   0          63s
```

The ArgoCD server remained healthy after the RBAC configuration.

## RBAC Architecture

```text
devops-readonly
       │
       ▼
bankapp-readonly
       │
       └── applications: get
                │
                ▼
        bankapp-project/*
```

This means the example group receives read-only access to Applications belonging to the `bankapp-project`.

## Interview Explanation

**Question: What is an ArgoCD Project?**

**Answer:**

> An ArgoCD Project provides a logical boundary for applications. It can restrict which Git repositories applications can use, which Kubernetes clusters and namespaces they can deploy to, and which resources they are allowed to manage.

**Question: What is ArgoCD RBAC?**

**Answer:**

> ArgoCD RBAC controls what users or groups can do inside ArgoCD. Roles can provide permissions such as viewing, synchronizing, or modifying applications. In this task I created a read-only role for Applications in the `bankapp-project`.

---

# Final Day 85 Architecture

The Day 85 implementation can be summarized as:

```text
                         Git Repository
                              │
                              ▼
                       ArgoCD Application
                              │
              ┌───────────────┼────────────────┐
              │               │                │
              ▼               ▼                ▼
        Sync Strategy    Sync Waves       App of Apps
              │               │                │
       Manual/Auto       -2 → -1 → 0      ┌────┼────┐
                              → 1 → 2      ▼    ▼    ▼
                                         Bank Monitoring Envoy
              │
              ▼
          Rollback
              │
              ▼
       Previous Revision


        ArgoCD Notifications
                 │
                 ▼
        Trigger → Template
                 │
                 ▼
          Notification


        ArgoCD Project
              │
              ├── Source Repository
              ├── Destinations
              └── Resource Permissions
                       │
                       ▼
                    RBAC
                       │
                       ▼
              Users / Groups / Roles
```

# Key GitOps Lessons Learned

## 1. Git is the Source of Truth

ArgoCD continuously compares the desired state stored in Git with the live Kubernetes state.

## 2. Automated Sync Reduces Manual Operations

With automated sync enabled, ArgoCD automatically reconciles changes from Git.

## 3. Manual Sync Provides Control

Manual synchronization allows an operator to review differences before applying them.

Useful commands include:

```bash
argocd app diff bankapp
argocd app sync bankapp --dry-run
argocd app sync bankapp
```

## 4. Sync Waves Control Deployment Order

Sync waves are useful when resources have dependencies.

Example:

```text
Namespace
   ↓
Storage
   ↓
Configuration
   ↓
Infrastructure
   ↓
Application
   ↓
HPA
```

## 5. Rollback Is an Operational Tool

ArgoCD can restore an application to an earlier revision.

For a permanent GitOps rollback, however, the Git repository should also represent the desired state.

## 6. App of Apps Improves Scalability

Instead of manually managing many ArgoCD Applications, a parent Application can manage child Applications from Git.

## 7. Notifications Improve Visibility

ArgoCD Notifications can notify teams when Application events occur.

## 8. Projects Provide Boundaries

ArgoCD Projects can restrict:

* Git repositories
* Kubernetes destinations
* Namespaces
* Cluster resources
* Namespace resources

## 9. RBAC Provides Controlled Access

RBAC allows organizations to give different users and groups different permissions.

---

# Important Commands Used

## Application status

```bash
kubectl get applications -n argocd
```

## Application diff

```bash
argocd app diff bankapp
```

## Manual synchronization

```bash
argocd app sync bankapp
```

## Synchronization dry run

```bash
argocd app sync bankapp --dry-run
```

## Application history

```bash
argocd app history bankapp
```

## Kubernetes application inspection

```bash
kubectl get application bankapp -n argocd
```

## AppProject inspection

```bash
kubectl get appproject bankapp-project -n argocd
```

## RBAC inspection

```bash
kubectl get configmap argocd-rbac-cm -n argocd -o yaml
```

## Notifications controller

```bash
kubectl get deployment -n argocd | grep notifications
```

---

# Final Status

| Task                     | Status     |
| ------------------------ | ---------- |
| Manual vs Automated Sync | ✅ Complete |
| Sync Waves               | ✅ Complete |
| Rollback                 | ✅ Complete |
| App of Apps              | ✅ Complete |
| Notifications            | ✅ Complete |
| Projects + RBAC          | ✅ Complete |

## Day 85 Conclusion

Day 85 provided hands-on experience with advanced ArgoCD features used in production GitOps environments.

The main takeaway is that ArgoCD is more than a deployment tool. It provides continuous reconciliation, controlled synchronization, deployment ordering, rollback capabilities, application hierarchy, notifications, project-level boundaries, and role-based access control.

The AI-BankApp project now demonstrates these ArgoCD concepts on an Amazon EKS cluster using Git as the desired-state source.

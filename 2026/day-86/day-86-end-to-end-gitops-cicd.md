# Day 86 — End-to-End CI/CD with GitHub Actions, DockerHub, ArgoCD & EKS

## Overview

Day 86 focused on building and validating a complete end-to-end GitOps CI/CD pipeline for the AI-BankApp application.

The final workflow is:

```text
Developer
   |
   | git push
   v
GitHub Repository
   |
   v
GitHub Actions
   |
   +--> Checkout
   |
   +--> Java 21
   |
   +--> Maven Build
   |
   +--> Tests
   |
   +--> Docker Build
   |
   +--> DockerHub Push
   |
   +--> Update Kubernetes Manifest
   |
   +--> Git Commit [skip ci]
   |
   v
Git Repository
   |
   v
ArgoCD
   |
   | detects Git change
   v
EKS Cluster
   |
   v
BankApp Deployment
   |
   v
Rolling Update
   |
   v
Running Application
```

The final deployment was successfully verified on Amazon EKS.

---

# 1. Day 86 Objectives

The main objectives were:

* Build a complete CI/CD pipeline using GitHub Actions.
* Build the Java application using Maven.
* Run automated tests.
* Build a Docker image.
* Push the image to DockerHub.
* Automatically update the Kubernetes Deployment manifest.
* Commit the updated image tag back to Git.
* Prevent the CI workflow from triggering itself using `[skip ci]`.
* Allow ArgoCD to detect the Git change.
* Deploy the new image to Amazon EKS.
* Verify Kubernetes rolling deployment.
* Troubleshoot ArgoCD synchronization problems.
* Troubleshoot cert-manager and Gateway API integration.
* Configure a working TLS certificate.
* Verify ArgoCD self-healing.

---

# 2. Environment

## Local Environment

Operating system:

```text
Ubuntu Linux
```

Repository:

```text
~/90DaysOfDevOps
```

Day 81 GitOps repository:

```text
~/90DaysOfDevOps/2026/day-81/AI-BankApp-DevOps-gitops
```

GitHub repository:

```text
https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git
```

Branch:

```text
feat/gitops
```

AWS region:

```text
us-west-2
```

EKS cluster:

```text
bankapp-eks
```

ArgoCD namespace:

```text
argocd
```

Application namespace:

```text
bankapp
```

DockerHub repository:

```text
shraddhawankhade/ai-bankapp-eks
```

---

# 3. CI/CD Architecture

The final architecture is:

```text
                    +----------------------+
                    |      Developer       |
                    +----------+-----------+
                               |
                               | git push
                               v
                    +----------------------+
                    |     GitHub Repo      |
                    |   feat/gitops branch |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |    GitHub Actions    |
                    +----------+-----------+
                               |
              +----------------+----------------+
              |                |                |
              v                v                v
        Maven Build        Tests          Docker Build
                                                 |
                                                 v
                                      +-------------------+
                                      |     DockerHub      |
                                      | ai-bankapp-eks    |
                                      +---------+---------+
                                                |
                                                |
                                  Update Kubernetes YAML
                                                |
                                                v
                                      +-------------------+
                                      |    Git Commit     |
                                      |    [skip ci]      |
                                      +---------+---------+
                                                |
                                                v
                                      +-------------------+
                                      |      ArgoCD       |
                                      +---------+---------+
                                                |
                                                v
                                      +-------------------+
                                      |     Amazon EKS    |
                                      |    bankapp-eks    |
                                      +---------+---------+
                                                |
                                                v
                                      +-------------------+
                                      |   BankApp Pods    |
                                      +-------------------+
```

---

# 4. GitOps Repository

The working repository was:

```bash
cd ~/90DaysOfDevOps/2026/day-81/AI-BankApp-DevOps-gitops
```

The GitOps branch was:

```text
feat/gitops
```

The repository used by ArgoCD:

```text
https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git
```

ArgoCD tracked:

```text
Branch: feat/gitops
Path: k8s
```

---

# 5. GitOps Application Configuration

The ArgoCD `bankapp` Application was configured to use:

```text
Repository:
https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git

Target Revision:
feat/gitops

Path:
k8s

Namespace:
bankapp
```

The sync policy was automated with pruning and self-healing.

Important settings included:

```text
Automated Sync
Prune
SelfHeal
CreateNamespace
ServerSideApply
```

---

# 6. GitHub Actions CI Pipeline

The workflow was:

```text
GitHub Push
     |
     v
Checkout source code
     |
     v
Setup JDK 21
     |
     v
Maven build
     |
     v
Run tests
     |
     v
Generate short Git SHA
     |
     v
Login to DockerHub
     |
     v
Build Docker image
     |
     v
Push Docker images
     |
     v
Update Kubernetes deployment YAML
     |
     v
Commit changes with [skip ci]
     |
     v
Push changes to feat/gitops
```

---

# 7. Docker Image

The final DockerHub repository was:

```text
shraddhawankhade/ai-bankapp-eks
```

The application image generated from the Day 86 application commit was:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

The workflow also maintained the `latest` image tag.

---

# 8. DockerHub Authentication

GitHub Actions used repository secrets for DockerHub authentication.

Configured secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

These secrets were used by the workflow to authenticate to DockerHub.

The DockerHub token was never stored directly inside the workflow file.

---

# 9. Initial CI/CD Problem

The first CI/CD implementation had an incorrect DockerHub image replacement pattern.

The workflow was originally based on the upstream project configuration.

The project was then changed to use the personal DockerHub repository:

```text
shraddhawankhade/ai-bankapp-eks
```

The GitOps image replacement was fixed.

Commit:

```text
f747185 fix: update gitops image replacement for personal dockerhub repo
```

This was an important correction because the CI pipeline needed to update the image reference in:

```text
k8s/bankapp-deployment.yml
```

to the personal DockerHub repository.

---

# 10. Day 86 Application Update

The bank application assistant message was updated for Day 86.

Commit:

```text
a3ff311 feat: update bankapp assistant message for day 86
```

This commit became the Git SHA used for the Docker image:

```text
a3ff311
```

Therefore the final image was:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

---

# 11. GitHub Actions Successful Run

The GitHub Actions workflow was:

```text
GitOps CI - Build & Push to DockerHub
```

Successful workflow run:

```text
37181245350
```

Final status:

```text
SUCCESS
```

The successful run performed:

```text
Checkout
JDK 21 setup
Maven build
Tests
Docker build
DockerHub login
Docker image push
Kubernetes manifest update
Git commit
Git push
```

---

# 12. CI Generated Git Commit

After building and pushing the Docker image, GitHub Actions updated the Kubernetes Deployment manifest.

The generated commit was:

```text
b3819d0 ci: update bankapp image to a3ff311 [skip ci]
```

The `[skip ci]` suffix was important.

It prevents the GitHub Actions workflow from continuously triggering itself after the workflow updates the Kubernetes manifest.

The flow therefore becomes:

```text
Application commit
      |
      v
GitHub Actions
      |
      v
Docker image build
      |
      v
Update Kubernetes YAML
      |
      v
[skip ci] commit
      |
      v
ArgoCD detects Git change
```

---

# 13. ArgoCD Initial Sync Problem

After CI successfully updated the image, ArgoCD detected the new Git revision.

However, the synchronization initially failed.

The application showed:

```text
Sync Status: OutOfSync
Health Status: Degraded
```

The important issue was not the BankApp Deployment itself.

The problem was the Gateway TLS configuration.

---

# 14. Deployment Health Check

The BankApp Deployment itself was healthy.

The deployment showed:

```text
2 desired
2 available
```

Therefore the application Deployment was not the cause of the ArgoCD sync failure.

The actual failure was related to the Gateway and TLS Secret.

---

# 15. ArgoCD Controller Troubleshooting

The ArgoCD application controller logs were checked using:

```bash
kubectl -n argocd logs pod/argocd-application-controller-0 --since=15m | grep -iE "bankapp|sync|error|failed" | tail -100
```

The logs showed that the Gateway failed because:

```text
Secret bankapp/bankapp-tls does not exist
```

The operation was therefore unable to reach a healthy state.

ArgoCD was waiting for the required TLS resource.

---

# 16. TLS Certificate Problem

The BankApp Gateway used HTTPS.

The HTTPS listener referenced:

```text
bankapp-tls
```

However, the Secret did not exist.

The Gateway status showed:

```text
InvalidCertificateRef
```

with the reason:

```text
Secret bankapp/bankapp-tls does not exist
```

This caused:

```text
Gateway -> Degraded
ArgoCD Application -> Degraded
ArgoCD Sync -> Failed
```

---

# 17. Certificate Resource

A cert-manager `Certificate` resource was added to:

```text
k8s/cert-manager.yml
```

The configuration was:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: bankapp-tls
  namespace: bankapp
spec:
  secretName: bankapp-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - 54.200.19.53.nip.io
```

The Certificate resource was required so cert-manager could create:

```text
Secret/bankapp-tls
```

---

# 18. Stale IP Address Discovery

During troubleshooting, the Gateway hostname was found to contain an old IP address:

```text
54.200.19.53.nip.io
```

The actual AWS LoadBalancer DNS name was:

```text
a63627a59fda1482badf15b8faba9098-653355831.us-west-2.elb.amazonaws.com
```

The LoadBalancer resolved to:

```text
54.201.132.123
```

However:

```text
54.200.19.53.nip.io
```

resolved to:

```text
54.200.19.53
```

Therefore the DNS hostname was pointing to the wrong endpoint.

---

# 19. Proving the Kubernetes Routing Was Working

Instead of testing the stale public IP directly, the actual AWS LoadBalancer DNS name was tested while manually setting the Host header.

Command:

```bash
curl -i \
  -H 'Host: 54.200.19.53.nip.io' \
  http://a63627a59fda1482badf15b8faba9098-653355831.us-west-2.elb.amazonaws.com/.well-known/acme-challenge/q9b7p2eOYgAlY2SHZpsAuDGFH1Kc0pFa-n7yBSPe1pM
```

The response was:

```text
HTTP/1.1 200
```

The challenge response was returned successfully:

```text
q9b7p2eOYgAlY2SHZpsAuDGFH1Kc0pFa-n7yBSPe1pM.1NeIM5QwiSRrmYH1qvK0-NM6ptKaTaoRxP1AMTBNTIUshraddha
```

This proved that:

```text
AWS LoadBalancer
        |
        v
Gateway
        |
        v
HTTPRoute
        |
        v
ACME Solver
```

was working.

The real problem was the stale IP-based hostname.

---

# 20. Updating the Gateway Hostname

The stale hostname was searched inside the Kubernetes manifests:

```bash
grep -Rni "54.200.19.53" k8s/
```

It was found in:

```text
k8s/cert-manager.yml
k8s/gateway.yml
```

The old hostname:

```text
54.200.19.53.nip.io
```

was replaced with:

```text
54.201.132.123.nip.io
```

The updated hostname was used consistently by:

```text
Certificate
Gateway
HTTPRoute
```

---

# 21. Manifest Validation

The Gateway manifest was validated using:

```bash
kubectl apply --dry-run=client -f k8s/gateway.yml
```

The command succeeded.

The cert-manager manifest was validated using:

```bash
kubectl apply --dry-run=client -f k8s/cert-manager.yml
```

The command also succeeded.

---

# 22. Git Status After TLS Fix

The repository showed:

```text
 M k8s/cert-manager.yml
 M k8s/gateway.yml
?? argocd/projects/
```

The important modified files were:

```text
k8s/cert-manager.yml
k8s/gateway.yml
```

The TLS hostname correction was committed as:

```text
708d9d2 fix: update bankapp gateway hostname
```

The commit was pushed successfully to:

```text
feat/gitops
```

---

# 23. cert-manager Gateway API Configuration

Another important troubleshooting step involved cert-manager.

The installed cert-manager version was:

```text
v1.21.2
```

Helm release:

```text
cert-manager
```

Namespace:

```text
cert-manager
```

The initial Helm values contained only:

```yaml
crds:
  enabled: true
```

The cert-manager Helm chart was inspected to find the Gateway API configuration.

The chart showed:

```yaml
gatewayAPI:
  enabled: true
```

inside the controller configuration.

The correct Helm value was therefore:

```text
config.gatewayAPI.enabled=true
```

not:

```text
config.enableGatewayAPI=true
```

---

# 24. cert-manager Helm Upgrade

The successful Helm command was:

```bash
helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.21.2 \
  --reuse-values \
  --set 'config.gatewayAPI.enabled=true' \
  --wait \
  --timeout 10m
```

The upgrade completed successfully.

The Helm release reached:

```text
Revision: 4
Status: deployed
```

The live cert-manager controller then used:

```text
--config=/var/cert-manager/config/config.yaml
```

The generated configuration contained:

```yaml
apiVersion: controller.config.cert-manager.io/v1alpha1
gatewayAPI:
  enabled: true
kind: ControllerConfiguration
```

---

# 25. cert-manager Pods

The cert-manager components were verified and were running successfully.

The important state was:

```text
cert-manager controller    1/1 Running
cert-manager webhook       1/1 Running
cert-manager cainjector    1/1 Running
```

Gateway API support was therefore enabled in the running cert-manager controller.

---

# 26. ACME HTTP-01 Challenge

The ACME challenge initially failed because Gateway API support had not been enabled.

The initial reason was:

```text
gateway api is not enabled
```

After enabling Gateway API support, cert-manager retried the challenge.

The challenge resource was:

```text
bankapp-tls-1-2118431989-1084498632
```

The solver HTTPRoute was:

```text
cm-acme-http-solver-54gjm
```

The solver route used:

```text
/.well-known/acme-challenge/
```

and was attached to:

```text
bankapp-gateway
```

---

# 27. ACME Challenge Propagation

Before the hostname correction, the ACME challenge returned:

```text
403
```

The expected response was:

```text
200
```

The problem was eventually traced to the stale hostname.

After using the correct LoadBalancer IP:

```text
54.201.132.123
```

the challenge route returned:

```text
HTTP 200
```

This allowed the ACME HTTP-01 validation to succeed.

---

# 28. ArgoCD Stuck Operation

During the troubleshooting process, ArgoCD had an older synchronization operation already running.

Running another sync produced:

```text
rpc error: code = FailedPrecondition desc = another operation is already in progress
```

The active operation was inspected with:

```bash
argocd app get bankapp -o json | jq '.status.operationState'
```

The operation was waiting for:

```text
Certificate/bankapp-tls
```

The old operation was terminated using:

```bash
argocd app terminate-op bankapp
```

After termination, the application could be synchronized again using the corrected Git revision.

---

# 29. Verifying ArgoCD Desired Certificate

The desired Git manifest was checked with:

```bash
argocd app manifests bankapp --source git | \
awk '/^apiVersion: cert-manager.io\/v1/{flag=1} flag{print} /^---$/{if(flag){exit}}'
```

The final desired Certificate contained:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  annotations:
    argocd.argoproj.io/tracking-id: bankapp:cert-manager.io/Certificate:bankapp/bankapp-tls
  name: bankapp-tls
  namespace: bankapp
spec:
  dnsNames:
  - 54.201.132.123.nip.io
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: bankapp-tls
```

This confirmed that ArgoCD was now reading the corrected hostname from Git.

---

# 30. Successful ArgoCD Synchronization

The application was synchronized again.

Command:

```bash
argocd app sync bankapp
```

The synchronization succeeded.

Important resources became:

```text
bankapp-tls          Synced     Healthy
Gateway              Synced     Healthy
HTTPRoute            Synced     Healthy
ClusterIssuer        Synced     Healthy
Deployment bankapp   Synced     Healthy
HPA                  Synced     Healthy
```

The final ArgoCD state was:

```text
Name:               argocd/bankapp
Project:             default
Server:              https://kubernetes.default.svc
Namespace:           bankapp

Source:
- Repo:             https://github.com/Shraddha5-stack/AI-BankApp-DevOps.git
  Target:           feat/gitops
  Path:              k8s

Sync Policy:
Automated (Prune)

Sync Status:
Synced to feat/gitops (708d9d2)

Health Status:
Healthy
```

Operation:

```text
Phase: Succeeded
```

Message:

```text
successfully synced (all tasks run)
```

The sync took approximately:

```text
1m31s
```

---

# 31. Certificate Final Status

The Certificate eventually became healthy.

The final certificate message was:

```text
Certificate is up to date and has not expired
```

The Secret created by cert-manager was:

```text
bankapp-tls
```

This allowed the HTTPS Gateway listener to become healthy.

---

# 32. Gateway Final Status

The Gateway became:

```text
Healthy
```

The HTTPRoute also became:

```text
Healthy
```

The previous:

```text
InvalidCertificateRef
```

condition was resolved.

---

# 33. Final CI/CD Deployment Verification

After the successful CI/CD pipeline and ArgoCD synchronization, the live Kubernetes Deployment image was checked.

Command:

```bash
kubectl get deployment bankapp -n bankapp \
  -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

Output:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

This confirmed that the image generated by GitHub Actions was running in EKS.

---

# 34. Kubernetes Rolling Update Verification

The deployment rollout was checked using:

```bash
kubectl rollout status deployment/bankapp -n bankapp
```

Output:

```text
deployment "bankapp" successfully rolled out
```

This confirmed that Kubernetes successfully completed the rolling update.

Therefore the complete deployment path worked:

```text
Git commit
   |
   v
GitHub Actions
   |
   v
DockerHub
   |
   v
Git manifest update
   |
   v
ArgoCD
   |
   v
EKS
   |
   v
New BankApp image
```

---

# 35. ArgoCD Self-Healing Test

ArgoCD was configured with:

```text
selfHeal: true
```

The current replica count was checked:

```bash
kubectl get deployment bankapp -n bankapp \
  -o jsonpath='{.spec.replicas}'; echo
```

Output:

```text
2
```

The deployment was intentionally changed:

```bash
kubectl scale deployment bankapp -n bankapp --replicas=1
```

Output:

```text
deployment.apps/bankapp scaled
```

The replica count was checked again.

ArgoCD automatically restored the desired state:

```text
2
```

This demonstrated that ArgoCD self-healing was working.

The recovery happened very quickly, but no exact recovery duration was recorded, so no precise recovery time is claimed.

---

# 36. Final ArgoCD Verification After Self-Healing

The application was refreshed:

```bash
argocd app get bankapp --refresh
```

Final state:

```text
Sync Status:
Synced to feat/gitops (708d9d2)

Health Status:
Healthy
```

The BankApp Deployment remained:

```text
Synced
Healthy
```

This confirmed that manual Kubernetes drift was automatically corrected.

---

# 37. Final Image Verification

The live image remained:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

This confirmed that:

1. GitHub Actions created the image.
2. DockerHub stored the image.
3. GitHub Actions updated the Kubernetes manifest.
4. ArgoCD detected the Git change.
5. ArgoCD deployed the image.
6. EKS successfully rolled out the new version.

---

# 38. Important Git Commits

The important Day 86 commits were:

### Application update

```text
a3ff311 feat: update bankapp assistant message for day 86
```

### DockerHub image replacement fix

```text
f747185 fix: update gitops image replacement for personal dockerhub repo
```

### CI-generated Kubernetes image update

```text
b3819d0 ci: update bankapp image to a3ff311 [skip ci]
```

### TLS Certificate fix

```text
b3552ff fix: add bankapp TLS certificate
```

### Gateway hostname correction

```text
708d9d2 fix: update bankapp gateway hostname
```

Final ArgoCD Git revision:

```text
708d9d2
```

Final application image:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

---

# 39. Complete Troubleshooting Summary

## Problem 1 — DockerHub Image Replacement

### Symptom

GitHub Actions was using the wrong DockerHub repository reference.

### Cause

The workflow was based on the original upstream project.

### Fix

Changed the image replacement to:

```text
shraddhawankhade/ai-bankapp-eks
```

Commit:

```text
f747185
```

---

## Problem 2 — Missing TLS Secret

### Symptom

ArgoCD showed:

```text
Degraded
```

Gateway showed:

```text
InvalidCertificateRef
```

### Cause

The Secret:

```text
bankapp-tls
```

did not exist.

### Fix

Added a cert-manager `Certificate` resource.

---

## Problem 3 — Gateway API Disabled in cert-manager

### Symptom

ACME challenge showed:

```text
gateway api is not enabled
```

### Cause

Gateway API support was not enabled in the running cert-manager controller.

### Fix

Used:

```bash
helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.21.2 \
  --reuse-values \
  --set 'config.gatewayAPI.enabled=true' \
  --wait \
  --timeout 10m
```

---

## Problem 4 — ACME Challenge Returned 403

### Symptom

cert-manager reported:

```text
wrong status code '403', expected '200'
```

### Investigation

The actual AWS LoadBalancer IP was:

```text
54.201.132.123
```

but the configured hostname pointed to:

```text
54.200.19.53
```

### Proof

The challenge worked when the request was sent through the actual LoadBalancer DNS name with the expected Host header.

### Root Cause

Stale IP-based hostname.

### Fix

Changed:

```text
54.200.19.53.nip.io
```

to:

```text
54.201.132.123.nip.io
```

---

## Problem 5 — ArgoCD Operation Already Running

### Symptom

Running another sync returned:

```text
another operation is already in progress
```

### Cause

An older synchronization operation was still waiting for the unhealthy Certificate.

### Fix

Terminated the old operation:

```bash
argocd app terminate-op bankapp
```

Then synchronized the corrected Git revision.

---

# 40. Final Architecture

The final architecture can be summarized as:

```text
                    DEVELOPER
                        |
                        |
                    git push
                        |
                        v
              +-------------------+
              |     GitHub        |
              |  feat/gitops      |
              +---------+---------+
                        |
                        v
              +-------------------+
              | GitHub Actions    |
              |                   |
              | Maven Build       |
              | Tests             |
              | Docker Build      |
              | Docker Push       |
              +---------+---------+
                        |
                        v
              +-------------------+
              |    DockerHub      |
              |                   |
              | ai-bankapp-eks     |
              |       :a3ff311     |
              +---------+---------+
                        |
                        |
                Update k8s YAML
                        |
                        v
              +-------------------+
              |     GitHub        |
              | [skip ci] commit  |
              +---------+---------+
                        |
                        v
              +-------------------+
              |      ArgoCD       |
              |                   |
              | Sync              |
              | Self-Heal         |
              | Prune             |
              +---------+---------+
                        |
                        v
              +-------------------+
              |    Amazon EKS     |
              |   bankapp-eks     |
              +---------+---------+
                        |
             +----------+----------+
             |                     |
             v                     v
      +-------------+       +-------------+
      |   Gateway   |       |  BankApp    |
      | Envoy       |       | Deployment  |
      +------+------+       +------+------+
             |                     |
             v                     v
       HTTPS/TLS              BankApp Pods
             |
             v
       cert-manager
             |
             v
       Let's Encrypt
```

---

# 41. Final Day 86 Status

| Component                  | Status                                    |
| -------------------------- | ----------------------------------------- |
| GitHub Actions             | PASS                                      |
| Maven Build                | PASS                                      |
| Tests                      | Completed                                 |
| Docker Build               | PASS                                      |
| DockerHub Push             | PASS                                      |
| Image Tag                  | `a3ff311`                                 |
| Kubernetes Manifest Update | PASS                                      |
| `[skip ci]` Commit         | PASS                                      |
| ArgoCD Detection           | PASS                                      |
| ArgoCD Sync                | PASS                                      |
| ArgoCD Health              | Healthy                                   |
| cert-manager               | Healthy                                   |
| Gateway API                | Healthy                                   |
| TLS Certificate            | Healthy                                   |
| Gateway                    | Healthy                                   |
| HTTPRoute                  | Healthy                                   |
| EKS Deployment             | Healthy                                   |
| Rolling Update             | PASS                                      |
| Live Image                 | `shraddhawankhade/ai-bankapp-eks:a3ff311` |
| Self-Healing Test          | PASS                                      |

---

# 42. Final End-to-End Proof

The most important proof of Day 86 is:

```text
Application Commit
       |
       v
GitHub Actions
       |
       v
DockerHub Image
       |
       v
Git Manifest Updated
       |
       v
ArgoCD
       |
       v
Amazon EKS
       |
       v
Running Image:
shraddhawankhade/ai-bankapp-eks:a3ff311
```

The deployment rollout returned:

```text
deployment "bankapp" successfully rolled out
```

ArgoCD returned:

```text
Synced
Healthy
```

The self-healing test restored the deployment from:

```text
1 replica
```

back to the desired:

```text
2 replicas
```

Therefore the Day 86 GitOps CI/CD pipeline was successfully implemented and validated.

---

# 43. What I Learned

## GitHub Actions

I learned how to build a CI pipeline that:

* checks out code,
* configures Java,
* builds the application,
* runs tests,
* creates Docker images,
* authenticates with DockerHub,
* pushes images,
* updates Kubernetes manifests,
* and commits the changes back to Git.

---

## Docker

I learned how to use Git SHA-based image tags.

Example:

```text
a3ff311
```

This provides a direct relationship between:

```text
Git Commit
      |
      v
Docker Image
      |
      v
Kubernetes Deployment
```

This makes deployments easier to trace and troubleshoot.

---

## GitOps

I learned that Kubernetes configuration should be stored in Git and that ArgoCD continuously compares:

```text
Desired State = Git
Actual State = Kubernetes
```

If they differ, ArgoCD can synchronize the cluster.

---

## ArgoCD Self-Healing

The replica drift test demonstrated:

```text
Desired:
2 replicas

Manual change:
1 replica

ArgoCD:
2 replicas
```

This is a practical demonstration of GitOps self-healing.

---

## cert-manager

I learned that cert-manager can automatically obtain and manage TLS certificates using ACME.

I also learned that Gateway API support must be correctly enabled in the cert-manager controller when using Gateway API HTTP-01 solvers.

---

## Troubleshooting

The most important troubleshooting lesson was:

Do not immediately assume the Kubernetes application is broken.

Instead, trace the request path:

```text
DNS
  |
  v
AWS LoadBalancer
  |
  v
Gateway
  |
  v
HTTPRoute
  |
  v
Service
  |
  v
Pod
```

The actual problem was a stale IP-based hostname, not the BankApp Deployment.

---

# 44. Interview Questions and Answers

## Q1. What is CI/CD?

CI/CD means Continuous Integration and Continuous Delivery/Deployment.

CI automatically builds and tests application changes.

CD automatically delivers those changes to the deployment environment.

In this project:

```text
GitHub Actions = CI
ArgoCD + EKS = CD
```

---

## Q2. Why did you use Git SHA as the Docker image tag?

Using a Git SHA gives every image a unique and traceable version.

For example:

```text
a3ff311
```

can be directly mapped to the Git commit that produced the image.

This is safer than using only:

```text
latest
```

because `latest` does not uniquely identify a version.

---

## Q3. Why did GitHub Actions update the Kubernetes manifest?

The pipeline used a GitOps approach.

After pushing the Docker image, GitHub Actions updated:

```text
k8s/bankapp-deployment.yml
```

with the new image tag.

ArgoCD then detected the Git change and deployed it to EKS.

---

## Q4. Why did you use `[skip ci]`?

Without `[skip ci]`, the commit generated by GitHub Actions could trigger the same workflow again.

This could create an unnecessary CI loop.

The commit was therefore:

```text
ci: update bankapp image to a3ff311 [skip ci]
```

---

## Q5. What is GitOps?

GitOps is a deployment model where Git acts as the source of truth for infrastructure and application configuration.

In this project:

```text
Git = Desired State
Kubernetes = Actual State
ArgoCD = Reconciliation Engine
```

---

## Q6. What is ArgoCD?

ArgoCD is a GitOps continuous delivery tool for Kubernetes.

It continuously monitors the configured Git repository and compares the desired state with the actual Kubernetes state.

---

## Q7. What is ArgoCD self-healing?

Self-healing means ArgoCD automatically restores Kubernetes resources when someone manually changes them away from the desired Git state.

The Day 86 test changed:

```text
2 replicas -> 1 replica
```

and ArgoCD restored:

```text
1 replica -> 2 replicas
```

---

## Q8. Why was the ArgoCD application initially Degraded?

The Gateway referenced:

```text
bankapp-tls
```

but the TLS Secret did not exist.

Therefore:

```text
Gateway = Degraded
ArgoCD = Degraded
```

The issue was resolved using cert-manager.

---

## Q9. What was the ACME challenge problem?

The ACME HTTP-01 challenge initially returned:

```text
403
```

instead of:

```text
200
```

The Kubernetes routing itself was working.

The hostname pointed to an old IP address.

After changing the hostname to the current LoadBalancer IP, the challenge returned:

```text
200
```

---

## Q10. Why did you need cert-manager?

cert-manager automates TLS certificate issuance and renewal.

In this project it was used with Let's Encrypt to obtain the TLS certificate required by the Gateway.

---

## Q11. What is an HTTP-01 challenge?

HTTP-01 is an ACME validation mechanism.

The Certificate Authority requests a special URL:

```text
/.well-known/acme-challenge/<token>
```

The ACME solver must return the expected response.

If validation succeeds, Let's Encrypt can issue the certificate.

---

## Q12. Why did you use `nip.io`?

`nip.io` provides DNS resolution based on an IP address.

For example:

```text
54.201.132.123.nip.io
```

resolves to:

```text
54.201.132.123
```

This is useful for testing without configuring a traditional DNS record.

However, for a production system, stable DNS is preferable because cloud LoadBalancer IP addresses can change.

---

## Q13. How did you verify that the deployment actually changed?

I used:

```bash
kubectl get deployment bankapp -n bankapp \
  -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

The result was:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

Then I verified the rollout:

```bash
kubectl rollout status deployment/bankapp -n bankapp
```

which returned:

```text
deployment "bankapp" successfully rolled out
```

---

## Q14. How do you troubleshoot an ArgoCD sync failure?

I would check:

```bash
argocd app get bankapp
```

Then:

```bash
argocd app get bankapp -o json
```

Then inspect the ArgoCD application controller logs:

```bash
kubectl -n argocd logs pod/argocd-application-controller-0
```

I would identify which resource is unhealthy and then troubleshoot that Kubernetes resource directly.

---

## Q15. What was the most important troubleshooting lesson from Day 86?

The most important lesson was to trace the entire request path rather than assuming the application itself was broken.

For the ACME problem:

```text
Hostname
   |
   v
AWS LoadBalancer
   |
   v
Gateway
   |
   v
HTTPRoute
   |
   v
ACME Solver
```

The solver worked correctly when accessed through the real LoadBalancer.

The actual issue was the stale hostname/IP.

---

# 45. Day 86 Key Commands

### Check image

```bash
kubectl get deployment bankapp -n bankapp \
  -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

### Check rollout

```bash
kubectl rollout status deployment/bankapp -n bankapp
```

### Check ArgoCD application

```bash
argocd app get bankapp --refresh
```

### Synchronize ArgoCD

```bash
argocd app sync bankapp
```

### Terminate stuck operation

```bash
argocd app terminate-op bankapp
```

### Check ArgoCD controller logs

```bash
kubectl -n argocd logs pod/argocd-application-controller-0 --since=15m | grep -iE "bankapp|sync|error|failed" | tail -100
```

### Check Deployment replicas

```bash
kubectl get deployment bankapp -n bankapp \
  -o jsonpath='{.spec.replicas}'; echo
```

### Test self-healing

```bash
kubectl scale deployment bankapp -n bankapp --replicas=1
```

### Check certificate

```bash
kubectl get certificate -n bankapp
```

### Check Gateway

```bash
kubectl get gateway -n bankapp
```

### Check HTTPRoute

```bash
kubectl get httproute -n bankapp
```

### Check cert-manager Helm release

```bash
helm list -A | grep -i cert-manager
```

### Check cert-manager configuration

```bash
helm get values cert-manager -n cert-manager
```

### Upgrade cert-manager Gateway API support

```bash
helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.21.2 \
  --reuse-values \
  --set 'config.gatewayAPI.enabled=true' \
  --wait \
  --timeout 10m
```

---

# 46. Final Day 86 Conclusion

Day 86 successfully implemented and validated an end-to-end GitOps CI/CD pipeline.

The final workflow was:

```text
Developer
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Maven
   +--> Tests
   +--> Docker Build
   +--> DockerHub Push
   |
   v
Kubernetes Manifest Update
   |
   v
Git Commit [skip ci]
   |
   v
ArgoCD
   |
   v
Amazon EKS
   |
   v
Rolling Deployment
   |
   v
Healthy BankApp
```

The final deployed image was:

```text
shraddhawankhade/ai-bankapp-eks:a3ff311
```

The final ArgoCD state was:

```text
Synced
Healthy
```

The Kubernetes rollout was:

```text
deployment "bankapp" successfully rolled out
```

The self-healing test successfully restored the desired replica count.

Therefore:

```text
DAY 86 — COMPLETE
```

---

# 47. Day 86 Interview Summary

If asked to explain this project in an interview:

> "I implemented an end-to-end GitOps CI/CD pipeline for an AI banking application. When I push application code to GitHub, GitHub Actions builds the Java application with Maven, runs tests, creates a Docker image tagged with the Git SHA, and pushes it to DockerHub. The workflow then updates the Kubernetes Deployment manifest in Git and commits the change with `[skip ci]`. ArgoCD monitors the GitOps repository and automatically synchronizes the updated manifest to an Amazon EKS cluster. I also configured cert-manager with Gateway API and Let's Encrypt for TLS. During troubleshooting, I found that the ACME challenge was failing because the nip.io hostname pointed to an outdated LoadBalancer IP. After correcting the hostname and enabling Gateway API support in cert-manager, the certificate and Gateway became healthy. Finally, I verified that the new Docker image was running in EKS, the rolling update completed successfully, and ArgoCD self-healed a manually introduced replica drift."

This demonstrates practical knowledge of:

```text
Git
GitHub Actions
CI/CD
Maven
Docker
DockerHub
Kubernetes
Amazon EKS
ArgoCD
GitOps
Gateway API
Envoy Gateway
cert-manager
Let's Encrypt
TLS
ACME
Self-Healing
Rolling Updates
Troubleshooting
```

---

# Day 86 Status: COMPLETE ✅

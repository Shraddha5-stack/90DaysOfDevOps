# Day 82 — EKS Networking with Gateway API and Persistent Storage

## 1. Architecture

```text
                    Internet
                        |
                        v
              AWS Network Load Balancer
                        |
                        v
             +----------------------+
             |    Envoy Gateway     |
             |   bankapp-gateway    |
             +----------------------+
                |                |
             HTTP :80         HTTPS :443
                                  |
                            TLS Termination
                                  |
                                  v
                         HTTPRoute
                       bankapp-route
                                  |
                                  v
                       bankapp-service
                           :8080
                                  |
                    +-------------+-------------+
                    |                           |
                    v                           v
              BankApp Pod                  BankApp Pod
                    |                           |
                    +-------------+-------------+
                                  |
                         Cookie Session
                           Affinity
                        BANKAPP_AFFINITY


        Persistent Storage
        -------------------

             MySQL Pod                 Ollama Pod
                 |                         |
                 v                         v
             mysql-pvc                 ollama-pvc
                5Gi                       10Gi
                 |                         |
                 v                         v
              AWS EBS                    AWS EBS
                gp3                       gp3
```

## 2. Gateway API vs Ingress

| Feature | Ingress | Gateway API |
|---|---|---|
| API maturity | Stable | GA since Kubernetes 1.26 |
| Traffic splitting | Limited/controller-specific | Built-in weighted backends |
| Header matching | Controller-specific | Native HTTPRoute support |
| TLS | Supported | Native TLS listener configuration |
| Role separation | Limited | GatewayClass, Gateway and HTTPRoute |
| Extensibility | More limited | Designed for advanced routing |
| Session affinity | Controller-specific | Implementation-specific |

Gateway API provides a more expressive and extensible model for Kubernetes
networking. It separates infrastructure configuration from application
routing and supports advanced HTTP routing features.


## 3. Envoy Gateway and GatewayClass

Envoy Gateway is used as the Gateway API implementation for this EKS
environment. It manages Envoy proxy infrastructure and exposes the
application through an AWS Network Load Balancer.

### GatewayClass

The GatewayClass defines which controller manages Gateway resources.

Current GatewayClass:

```text
Name:       envoy-gateway
Controller: gateway.envoyproxy.io/gatewayclass-controller
Accepted:   True
```

Verification command:

```bash
kubectl get gatewayclass
```

The output confirms:

```text
envoy-gateway   gateway.envoyproxy.io/gatewayclass-controller   True
```

`Accepted=True` means the Envoy Gateway controller has accepted and manages this GatewayClass.

## 4. Gateway and HTTPRoute

The application traffic is exposed through a Kubernetes Gateway resource managed by Envoy Gateway.

### Gateway

The `bankapp-gateway` uses the `envoy-gateway` GatewayClass. Envoy Gateway provisions an AWS Network Load Balancer for external traffic.

Live Gateway status:

```text
Name:        bankapp-gateway
Class:       envoy-gateway
Programmed:  True
Address:     a9dd6ca1fbc31474f96ee192f5a9f5f3-1885611052.us-west-2.elb.amazonaws.com
```

Verification command:

```bash
kubectl get gateway bankapp-gateway -n bankapp
```

### HTTPRoute

The `bankapp-route` defines how HTTP requests are routed from the Gateway to the BankApp Kubernetes Service.

Configured hostname:

```text
54.200.19.53.nip.io
```

The route uses `PathPrefix /` and forwards traffic to `bankapp-service` on port `8080`.

Verification command:

```bash
kubectl get httproute bankapp-route -n bankapp
```

The Gateway API traffic flow is:

```text
Internet
   |
   v
AWS Network Load Balancer
   |
   v
bankapp-gateway
   |
   v
bankapp-route
   |
   v
bankapp-service:8080
   |
   v
BankApp Pods
```

## 5. HTTPS and TLS with cert-manager

cert-manager is used to obtain and manage the TLS certificate for the BankApp Gateway. The certificate is issued through the `letsencrypt-prod` ClusterIssuer.

The HTTPS Gateway listener uses TLS termination. TLS traffic is terminated at the Gateway before requests are forwarded to the application Service.

### Certificate Status

```text
Certificate:   bankapp-tls
Ready:         True
Secret:        bankapp-tls
```

Verification command:

```bash
kubectl get certificate bankapp-tls -n bankapp
```

### Let's Encrypt ClusterIssuer

```text
ClusterIssuer: letsencrypt-prod
Ready:         True
```

Verification command:

```bash
kubectl get clusterissuer letsencrypt-prod
```

The ClusterIssuer uses Let's Encrypt to issue certificates. The Gateway API HTTP-01 solver is used for domain validation.

### TLS Secret

The issued certificate and private key are stored in the `bankapp-tls` Kubernetes Secret.

```text
Name: bankapp-tls
Type: kubernetes.io/tls
Data: 2
```

Verification command:

```bash
kubectl get secret bankapp-tls -n bankapp
```

### HTTPS Traffic Flow

```text
Client
  |
  | HTTPS :443
  v
bankapp-gateway
  |
  | TLS termination
  v
HTTPRoute bankapp-route
  |
  v
bankapp-service:8080
  |
  v
BankApp Pods
```

## 5. HTTPS and TLS with cert-manager

cert-manager is used to obtain and manage the TLS certificate for the BankApp Gateway. The certificate is issued through the `letsencrypt-prod` ClusterIssuer.

The HTTPS Gateway listener uses TLS termination. TLS traffic is terminated at the Gateway before requests are forwarded to the application Service.

### Certificate Status

```text
Certificate:   bankapp-tls
Ready:         True
Secret:        bankapp-tls
```

Verification command:

```bash
kubectl get certificate bankapp-tls -n bankapp
```

### Let's Encrypt ClusterIssuer

```text
ClusterIssuer: letsencrypt-prod
Ready:         True
```

Verification command:

```bash
kubectl get clusterissuer letsencrypt-prod
```

The ClusterIssuer uses Let's Encrypt to issue certificates. The Gateway API HTTP-01 solver is used for domain validation.

### TLS Secret

The issued certificate and private key are stored in the `bankapp-tls` Kubernetes Secret.

```text
Name: bankapp-tls
Type: kubernetes.io/tls
Data: 2
```

Verification command:

```bash
kubectl get secret bankapp-tls -n bankapp
```

### HTTPS Traffic Flow

```text
Client
  |
  | HTTPS :443
  v
bankapp-gateway
  |
  | TLS termination
  v
HTTPRoute bankapp-route
  |
  v
bankapp-service:8080
  |
  v
BankApp Pods
```

## 6. Persistent Storage with AWS EBS

The BankApp uses Kubernetes PersistentVolumeClaims (PVCs) backed by Amazon EBS volumes through the AWS EBS CSI driver.

### StorageClass

The `gp3` StorageClass uses the `ebs.csi.aws.com` provisioner.

```text
Name:                 gp3
Provisioner:          ebs.csi.aws.com
ReclaimPolicy:        Delete
VolumeBindingMode:    WaitForFirstConsumer
AllowVolumeExpansion: true
```

Verification command:

```bash
kubectl get storageclass gp3
```

`WaitForFirstConsumer` allows volume provisioning to consider the scheduling requirements of the workload. This is useful with EBS because EBS volumes are associated with an AWS Availability Zone.

### PersistentVolumeClaims

```text
PVC          Status   Capacity   Access Mode   StorageClass
mysql-pvc    Bound    5Gi        RWO            gp3
ollama-pvc   Bound    10Gi       RWO            gp3
```

Verification command:

```bash
kubectl get pvc -n bankapp
```

### PersistentVolumes

The PVCs are bound to dynamically provisioned PersistentVolumes.

```text
mysql-pvc  -> pvc-10f52ec7-e4b2-4237-8d7d-1645a147cb19 -> 5Gi -> gp3
ollama-pvc -> pvc-7ebacdc4-e077-404c-9982-258a74ff05f2 -> 10Gi -> gp3
```

Verification command:

```bash
kubectl get pv
```

### EBS Storage Flow

```text
MySQL / Ollama Pod
        |
        v
PersistentVolumeClaim (PVC)
        |
        v
PersistentVolume (PV)
        |
        v
gp3 StorageClass
        |
        v
AWS EBS Volume
```

## 7. MySQL Persistent Storage Test

To verify that MySQL data survives pod recreation, the MySQL pod was deleted while its PersistentVolumeClaim remained attached to the workload.

### Before Pod Deletion

The original MySQL pod was:

```text
mysql-778d8d585d-w6zzg
Node: ip-10-0-6-117.us-west-2.compute.internal
```

The MySQL database list included the application database:

```text
bankappdb
information_schema
mysql
performance_schema
sys
```

Verification command:

```bash
kubectl exec -n bankapp deploy/mysql -- mysql -uroot -pTest@123 -e "SHOW DATABASES;"
```

### Delete the MySQL Pod

The MySQL pod was deleted using:

```bash
kubectl delete pod -n bankapp -l app=mysql
```

Kubernetes recreated the MySQL pod automatically.

### Replacement Pod

The replacement pod was:

```text
mysql-778d8d585d-xz6fh
Node: ip-10-0-6-8.us-west-2.compute.internal
Status: 1/1 Running
```

The replacement pod was scheduled on a different EKS node, while the same MySQL PVC remained bound.

### After Pod Recreation

The database list was checked again and `bankappdb` was still present along with the MySQL system databases.

```text
bankappdb
information_schema
mysql
performance_schema
sys
```

The `mysql-pvc` remained:

```text
Status:        Bound
Capacity:      5Gi
Access Mode:   RWO
StorageClass:  gp3
```

### Persistence Result

The test demonstrates that MySQL application data is stored on persistent EBS-backed storage rather than inside the lifecycle of the MySQL pod. Deleting and recreating the pod did not remove the `bankappdb` database.

```text
MySQL Pod
    |
    v
mysql-pvc (5Gi)
    |
    v
AWS EBS gp3
    |
    v
Database survives pod recreation
```

## 8. Cookie-Based Session Affinity

The BankApp uses application sessions, so requests from the same logged-in user should consistently reach the same application pod.

The Envoy Gateway configuration uses an Envoy-specific `BackendTrafficPolicy` to provide cookie-based session affinity.

### BackendTrafficPolicy

```text
Policy:          bankapp-session
Target:          bankapp-route
Algorithm:       ConsistentHash
Session source:  Cookie
Cookie:          BANKAPP_AFFINITY
TTL:             3600 seconds
Accepted:        True
```

Verification command:

```bash
kubectl get backendtrafficpolicy bankapp-session -n bankapp
```

### How Cookie Affinity Works

```text
User Login
    |
    v
Gateway
    |
    | BANKAPP_AFFINITY cookie
    v
Consistent Hashing
    |
    +-----------> BankApp Pod A
    |
    |
    +-----------> Same Pod for subsequent requests
```

The affinity cookie helps keep a user session associated with the same backend pod. This is useful when application sessions are stored in pod-local memory.

Without session affinity, consecutive requests could be routed to different pods, which can cause problems for applications that keep login session state in memory.

### Important Limitation

Cookie-based session affinity is an implementation-specific feature provided by Envoy Gateway rather than a standardized Gateway API session-affinity mechanism.

## 8. Cookie-Based Session Affinity

The BankApp uses application sessions, so requests from the same logged-in user should consistently reach the same application pod.

The Envoy Gateway configuration uses an Envoy-specific `BackendTrafficPolicy` to provide cookie-based session affinity.

### BackendTrafficPolicy

```text
Policy:          bankapp-session
Target:          bankapp-route
Algorithm:       ConsistentHash
Session source:  Cookie
Cookie:          BANKAPP_AFFINITY
TTL:             3600 seconds
Accepted:        True
```

Verification command:

```bash
kubectl get backendtrafficpolicy bankapp-session -n bankapp
```

### How Cookie Affinity Works

```text
User Login
    |
    v
Gateway
    |
    | BANKAPP_AFFINITY cookie
    v
Consistent Hashing
    |
    v
BankApp Pod
    |
    v
Subsequent requests remain associated with the same backend pod
```

The affinity cookie helps keep a user session associated with the same backend pod. This is useful when application sessions are stored in pod-local memory.

Without session affinity, consecutive requests could be routed to different pods, which can cause problems for applications that keep login session state in memory.

### Important Limitation

Cookie-based session affinity is an implementation-specific feature provided by Envoy Gateway rather than a standardized Gateway API session-affinity mechanism.

## 9. HPA and EKS Resource Capacity

The BankApp Deployment is configured with a Horizontal Pod Autoscaler (HPA) to scale based on CPU utilization.

### Current HPA Status

```text
Name:       bankapp-hpa
Target:     Deployment/bankapp
CPU Target: 70%
Min Pods:   2
Max Pods:   4
Replicas:   2
Current CPU: 1%
```

Verification command:

```bash
kubectl get hpa bankapp-hpa -n bankapp
```

The HPA currently maintains 2 BankApp replicas because CPU utilization is low. It can scale the Deployment up to 4 replicas when the configured CPU target requires additional capacity.

### EKS Node Capacity

The EKS cluster currently contains 4 Ready worker nodes running Kubernetes v1.35.8-eks-f4fc4f1.

```text
Node count: 4
Status:     Ready
Kubernetes: v1.35.8-eks-f4fc4f1
```

Verification command:

```bash
kubectl get nodes
```

Current node utilization:

```text
Node                                      CPU     Memory
ip-10-0-4-20.us-west-2.compute.internal   2%      32%
ip-10-0-5-131.us-west-2.compute.internal  1%      41%
ip-10-0-6-117.us-west-2.compute.internal  1%      41%
ip-10-0-6-8.us-west-2.compute.internal    1%      39%
```

Verification command:

```bash
kubectl top nodes
```

The current resource usage shows available capacity across the worker nodes for the BankApp workloads.

## 10. Day 82 Verification Summary

The Day 82 EKS networking and persistent storage setup was verified using the live Kubernetes cluster.

| Component | Status | Verification |
|---|---|---|
| EKS cluster | Running | `kubectl get nodes` |
| Envoy GatewayClass | Accepted | `kubectl get gatewayclass` |
| BankApp Gateway | Programmed | `kubectl get gateway -n bankapp` |
| HTTPRoute | Configured | `kubectl get httproute -n bankapp` |
| TLS Certificate | Ready | `kubectl get certificate -n bankapp` |
| Let's Encrypt ClusterIssuer | Ready | `kubectl get clusterissuer` |
| MySQL PVC | Bound | `kubectl get pvc -n bankapp` |
| Ollama PVC | Bound | `kubectl get pvc -n bankapp` |
| MySQL persistence | Verified | Pod deletion and database check |
| Session affinity | Accepted | `kubectl get backendtrafficpolicy -n bankapp` |
| BankApp HPA | Active | `kubectl get hpa -n bankapp` |

### Key Learnings

- Gateway API provides a structured model for Kubernetes traffic management.
- GatewayClass connects Gateway resources to the Envoy Gateway controller.
- Gateway and HTTPRoute separate infrastructure-level networking from application routing.
- Envoy Gateway provisions an AWS Network Load Balancer for external traffic in this setup.
- cert-manager automates TLS certificate management with Let's Encrypt.
- AWS EBS provides persistent storage for stateful workloads such as MySQL.
- PVCs provide Kubernetes workloads with persistent storage independently of pod lifecycle.
- Cookie-based session affinity can keep application sessions associated with the same backend pod.
- HPA allows the BankApp Deployment to scale between 2 and 4 replicas based on CPU utilization.

## 11. Conclusion

Day 82 demonstrated how an EKS-based application can use Gateway API for external traffic, Envoy Gateway for ingress infrastructure, cert-manager for HTTPS, AWS EBS for persistent storage, cookie-based session affinity for application sessions, and HPA for workload scaling.

The MySQL persistence test provided practical evidence that application data survived pod deletion and recreation because the database was stored on persistent EBS-backed storage.

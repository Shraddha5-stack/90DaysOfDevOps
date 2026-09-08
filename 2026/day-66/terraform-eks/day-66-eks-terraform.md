# Day 66 — Terraform + AWS EKS 🚀

## 📌 Overview

Day 66 focused on deploying a production-style Kubernetes environment on AWS using Terraform.

In this lab, I used Terraform to provision:

- AWS VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- AWS EKS Cluster
- EKS Managed Node Group
- IAM roles and policies
- KMS encryption
- CloudWatch logging

After creating the EKS cluster, I connected to it using `kubectl` and deployed an Nginx application.

I also practiced:

- Kubernetes Deployments
- Kubernetes Services
- AWS LoadBalancer
- Scaling
- Pod scheduling
- Rolling updates
- Terraform dependencies
- Terraform cleanup

---

# 🎯 Objectives

By completing this lab, I wanted to understand:

1. How Terraform provisions AWS infrastructure.
2. How Terraform creates an EKS cluster.
3. How EKS worker nodes are managed.
4. How Kubernetes applications run on EKS.
5. How a Kubernetes `LoadBalancer` creates an AWS Load Balancer.
6. How Kubernetes scheduling works when nodes have limited pod capacity.
7. How rolling updates work.
8. How Terraform dependency graphs work.
9. How to safely destroy AWS infrastructure after completing a lab.

---

# 🛠️ Technologies Used

- Terraform
- AWS
- Amazon EKS
- Amazon EC2
- Amazon VPC
- IAM
- AWS KMS
- CloudWatch
- Kubernetes
- kubectl
- Nginx
- Linux
- Git

---

# 📁 Project Structure

```text
terraform-eks/
├── eks.tf
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── providers.tf
├── screenshots/
│   ├── 01-eks-nodes-ready.png
│   ├── 02-nginx-pods-running.png
│   ├── 03-deployment-and-loadbalancer.png
│   ├── 04-rolling-update-success.png
│   └── 05-nginx-loadbalancer-response.png
├── terraform.tfvars
├── variables.tf
├── vpc.tf
└── day-66-eks-terraform.md
````

> `terraform.tfstate` and `terraform.tfstate.backup` should not be committed to GitHub.

---

# 1. Check Terraform Version

```bash
terraform version
```

Terraform version used:

```text
Terraform v1.16.0
```

---

# 2. Check AWS CLI

```bash
aws --version
```

AWS CLI was configured for:

```text
Region: ap-south-1
```

---

# 3. Verify AWS Identity

```bash
aws sts get-caller-identity
```

This confirmed that Terraform was using the correct AWS IAM user.

---

# 4. Terraform Provider

The AWS provider was configured to use the Mumbai region:

```hcl
provider "aws" {
  region = var.region
}
```

---

# 5. Terraform Provider Version Constraints

I learned the difference between:

```text
~> 5.0
>= 5.0
= 5.0.0
```

### `~> 5.0`

Allows compatible versions within the 5.x range.

### `>= 5.0`

Allows version 5.0 or newer.

### `= 5.0.0`

Requires exactly version 5.0.0.

---

# 6. Terraform Initialization

```bash
terraform init
```

This initialized Terraform and downloaded the required providers and modules.

---

# 7. Terraform Validation

```bash
terraform validate
```

This verifies that the Terraform configuration is syntactically valid.

---

# 8. Terraform Plan

```bash
terraform plan
```

The initial plan showed:

```text
Plan: 55 to add, 0 to change, 0 to destroy.
```

This allowed me to review the infrastructure before creating it.

---

# 9. AWS VPC Architecture

The infrastructure included:

```text
VPC
│
├── Public Subnet
│   ├── Internet Gateway
│   └── Load Balancer
│
├── Public Subnet
│
├── Private Subnet
│   └── EKS Worker Nodes
│
└── Private Subnet
    └── EKS Worker Nodes
```

The VPC CIDR was:

```text
10.0.0.0/16
```

The EKS worker nodes were deployed into private subnets.

---

# 10. EKS Cluster Configuration

Cluster name:

```text
terraweek-eks
```

Region:

```text
ap-south-1
```

Kubernetes version:

```text
1.31
```

The cluster used:

* Public endpoint access
* Private endpoint access
* KMS encryption
* CloudWatch logging

Enabled cluster logs included:

* API
* Audit
* Authenticator

---

# 11. EKS Managed Node Group

Managed node group:

```text
terraweek_nodes
```

Configuration:

```text
Instance Type: t3.micro
Desired: 2
Minimum: 1
Maximum: 3
```

The original configuration used `t3.medium`, but the node group failed because the instance type was not eligible for the available Free Tier usage.

I changed it to:

```text
t3.micro
```

Terraform then replaced the failed node group.

---

# 12. EKS Node Verification

I updated the Kubernetes configuration:

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name terraweek-eks
```

Then selected the EKS context:

```bash
kubectl config use-context \
  arn:aws:eks:ap-south-1:517724590868:cluster/terraweek-eks
```

Checked the worker nodes:

```bash
kubectl get nodes
```

Result:

```text
NAME                                        STATUS   ROLES    AGE   VERSION
ip-10-0-3-224.ap-south-1.compute.internal   Ready    <none>   ...   v1.31.13-eks-ecaa3a6
ip-10-0-4-17.ap-south-1.compute.internal    Ready    <none>   ...   v1.31.13-eks-ecaa3a6
```

Both worker nodes were `Ready`.

---

# 13. EKS Authentication

Initially, `kubectl` returned:

```text
the server has asked the client to provide credentials
```

I checked the EKS authentication configuration and discovered that the IAM user did not yet have an EKS access entry.

I created an access entry:

```bash
aws eks create-access-entry \
  --cluster-name terraweek-eks \
  --principal-arn arn:aws:iam::517724590868:user/terraform_base \
  --region ap-south-1
```

Then associated the EKS cluster administrator policy:

```bash
aws eks associate-access-policy \
  --cluster-name terraweek-eks \
  --principal-arn arn:aws:iam::517724590868:user/terraform_base \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster \
  --region ap-south-1
```

After this, `kubectl` authentication worked successfully.

---

# 14. Kubernetes Deployment

Created:

```text
k8s/deployment.yaml
```

Deployment configuration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: default
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
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
          image: nginx:1.27
          ports:
            - containerPort: 80
```

Applied using:

```bash
kubectl apply -f k8s/deployment.yaml
```

---

# 15. Verify Pods

```bash
kubectl get pods -o wide
```

The Nginx pods were running successfully.

---

# 16. Kubernetes Service

Created:

```text
k8s/service.yaml
```

Configuration:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Applied using:

```bash
kubectl apply -f k8s/service.yaml
```

---

# 17. AWS Load Balancer

The Kubernetes `LoadBalancer` service created an AWS Load Balancer.

Checked it using:

```bash
kubectl get svc nginx
```

The service exposed:

```text
PORT(S): 80
```

The AWS Load Balancer DNS name was:

```text
a04bb40e52d7e4f848b76be310ce68d0-414295492.ap-south-1.elb.amazonaws.com
```

---

# 18. Test the Application

I tested the application using:

```bash
curl http://a04bb40e52d7e4f848b76be310ce68d0-414295492.ap-south-1.elb.amazonaws.com
```

The request returned the Nginx welcome page successfully.

This confirmed:

```text
Internet
   ↓
AWS Load Balancer
   ↓
Kubernetes Service
   ↓
Nginx Pods
   ↓
EKS Worker Nodes
```

---

# 19. Kubernetes Scaling

I tested scaling the deployment:

```bash
kubectl scale deployment nginx --replicas=3
```

The third pod remained in:

```text
Pending
```

I investigated using:

```bash
kubectl describe pod <pod-name>
```

The scheduler reported:

```text
0/2 nodes are available: 2 Too many pods.
```

This was an important practical lesson.

The worker nodes had limited pod capacity.

I checked:

```bash
kubectl describe nodes | grep -E "Name:|pods:"
```

Both nodes had reached their available pod capacity.

---

# 20. Scale Back

I reduced the deployment back to two replicas:

```bash
kubectl scale deployment nginx --replicas=2
```

Then verified:

```bash
kubectl get pods
```

Both Nginx pods returned to:

```text
Running
```

---

# 21. Rolling Update

I changed the Nginx image:

```bash
kubectl set image deployment/nginx nginx=nginx:1.27
```

Then checked:

```bash
kubectl rollout status deployment/nginx
```

The rollout initially waited because the cluster had limited pod capacity.

To control the rollout more safely, I configured:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 0
    maxUnavailable: 1
```

This allowed Kubernetes to terminate one old pod before creating the replacement.

After applying the updated Deployment:

```bash
kubectl apply -f k8s/deployment.yaml
```

I verified:

```bash
kubectl rollout status deployment/nginx
```

Result:

```text
deployment "nginx" successfully rolled out
```

---

# 22. Verify Nginx Version

```bash
kubectl get deployment nginx \
  -o=jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Result:

```text
nginx:1.27
```

---

# 23. Terraform Dependency Graph

Terraform automatically determines resource creation order through dependencies.

Example:

```hcl
aws_subnet.main.vpc_id = aws_vpc.main.id
```

This creates an implicit dependency:

```text
VPC
 ↓
Subnet
```

When Terraform cannot automatically determine a dependency, we can use:

```hcl
depends_on
```

The dependency graph can be visualized using:

```bash
terraform graph
```

---

# 24. Terraform Lifecycle Rules

I practiced Terraform lifecycle concepts:

### create_before_destroy

Creates a replacement resource before destroying the old resource.

### prevent_destroy

Prevents Terraform from destroying a resource.

### ignore_changes

Allows Terraform to ignore selected changes made outside Terraform.

These lifecycle rules are useful when managing production infrastructure safely.

---

# 25. Important Terraform Commands

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform validate
```

### Format

```bash
terraform fmt
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

### Show State

```bash
terraform show
```

### List Resources

```bash
terraform state list
```

### Destroy

```bash
terraform destroy
```

---

# 26. Cleanup and Troubleshooting

After completing the lab and capturing the screenshots, I ran:

```bash
terraform destroy
```

Terraform initially encountered AWS dependency errors.

The VPC subnets could not be deleted because the AWS Load Balancer still had network interfaces attached.

I investigated the ENIs using:

```bash
aws ec2 describe-network-interfaces \
  --filters Name=vpc-id,Values=vpc-077d0794379ab88f6 \
  --query 'NetworkInterfaces[*].[NetworkInterfaceId,Status,SubnetId,Description]' \
  --output table
```

The result showed ELB-related network interfaces.

I discovered that a Classic Load Balancer was still present and removed it:

```bash
aws elb delete-load-balancer \
  --load-balancer-name a04bb40e52d7e4f848b76be310ce68d0 \
  --region ap-south-1
```

After waiting for AWS to release the ENIs, I verified again.

The ENIs were gone.

I then ran:

```bash
terraform destroy
```

The remaining resources were successfully removed.

---

# 27. Screenshots

The following screenshots document the completed lab:

### Screenshot 1 — EKS Nodes

```text
screenshots/01-eks-nodes-ready.png
```

Shows both EKS worker nodes in `Ready` state.

### Screenshot 2 — Nginx Pods

```text
screenshots/02-nginx-pods-running.png
```

Shows the Nginx pods running on EKS.

### Screenshot 3 — Deployment and LoadBalancer

```text
screenshots/03-deployment-and-loadbalancer.png
```

Shows the Kubernetes deployment and LoadBalancer service.

### Screenshot 4 — Rolling Update

```text
screenshots/04-rolling-update-success.png
```

Shows the successful Nginx rolling update.

### Screenshot 5 — Application Response

```text
screenshots/05-nginx-loadbalancer-response.png
```

Shows the Nginx welcome page returned through the AWS Load Balancer.

---

# 🧠 Key Learnings

## Terraform

I learned how Terraform:

* Uses providers to communicate with cloud platforms.
* Creates infrastructure declaratively.
* Builds dependency graphs.
* Handles implicit dependencies.
* Supports explicit dependencies using `depends_on`.
* Uses lifecycle rules.
* Manages infrastructure through state.

## AWS EKS

I learned:

* How to create an EKS cluster with Terraform.
* How managed node groups work.
* How IAM authentication works with EKS.
* How EKS worker nodes run Kubernetes workloads.
* How AWS networking integrates with Kubernetes.

## Kubernetes

I practiced:

* Deployments
* Pods
* Services
* LoadBalancer services
* Scaling
* Scheduling
* Rolling updates
* Rollout status
* Troubleshooting Pending pods

## AWS Load Balancer

I learned that creating a Kubernetes:

```yaml
type: LoadBalancer
```

can provision an AWS Load Balancer and connect external traffic to Kubernetes workloads.

---

# 💡 Biggest Takeaway

The biggest lesson from this project was understanding that **cloud infrastructure and Kubernetes are deeply connected**.

The architecture I built was:

```text
Terraform
   ↓
AWS VPC
   ↓
EKS Cluster
   ↓
Managed Node Group
   ↓
Kubernetes
   ↓
Deployment
   ↓
Pods
   ↓
Service
   ↓
AWS Load Balancer
   ↓
Internet
```

Terraform manages the infrastructure, while Kubernetes manages the workloads running on that infrastructure.

---

# 🚀 Day 66 Conclusion

Day 66 gave me practical experience deploying Kubernetes infrastructure on AWS using Terraform.

I learned not only how to create infrastructure, but also how to troubleshoot real problems such as:

* IAM permission issues
* EKS authentication
* Failed node group creation
* EC2 instance type limitations
* Kubernetes pod scheduling
* Rolling update capacity
* AWS Load Balancer dependencies
* Terraform destroy failures

This was a valuable step forward in my **Terraform + AWS + Kubernetes + DevOps journey**.

---

# 🏷️ Tags

#90DaysOfDevOps
#Terraform
#AWS
#EKS
#Kubernetes
#DevOps
#InfrastructureAsCode
#IaC
#CloudComputing
#TerraWeek
#DevOpsKaJosh
#TrainWithShubham

````

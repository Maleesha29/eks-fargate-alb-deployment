# 📦 AWS EKS Fargate Deployment with ALB Ingress

This project demonstrates how to deploy a containerized application on **Amazon EKS using AWS Fargate** and expose it externally using the **AWS Load Balancer Controller (ALB Ingress)**.

---

## 📌 Project Overview

The project provisions an EKS cluster in AWS, configures Fargate profiles for serverless pod execution, sets up IAM OIDC integration, installs the AWS Load Balancer Controller using Helm, and deploys a sample Kubernetes application accessible through an Application Load Balancer (ALB).

---

## 🏗️ Architecture

The system follows a cloud-native request flow:

- The user accesses the application via a browser.
- Requests are routed through an AWS Application Load Balancer (ALB).
- The AWS Load Balancer Controller (running inside EKS) manages ALB provisioning and routing.
- Traffic is forwarded to Kubernetes services.
- Services route traffic to pods running on AWS Fargate.

---

## 🧰 Technologies Used

- Amazon EKS
- AWS Fargate
- Kubernetes
- AWS Load Balancer Controller
- IAM OIDC
- Helm
- eksctl
- kubectl
- AWS CLI

---

## ⚙️ Prerequisites

Ensure the following tools are installed:

- AWS CLI
- eksctl
- kubectl
- Helm

Configure AWS credentials:

```bash
aws configure
```

---

# 🚀 How to Run the Project

Follow these steps to deploy the application.

---

## 🔹 1. Create EKS Cluster (Fargate)

```bash
eksctl create cluster --name demo-cluster --region us-east-1 --fargate
```

---

## 🔹 2. Update kubeconfig

```bash
aws eks update-kubeconfig --name demo-cluster --region us-east-1
```

---

## 🔹 3. Create Fargate Profile

```bash
eksctl create fargateprofile \
  --cluster demo-cluster \
  --region us-east-1 \
  --name alb-sample-app \
  --namespace game-2048
```

---

## 🔹 4. Associate IAM OIDC Provider

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster demo-cluster \
  --approve
```

---

## 🔹 5. Download IAM Policy

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
```

---

## 🔹 6. Create IAM Policy

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

---

## 🔹 7. Create IAM Service Account

👉 Replace `<ACCOUNT_ID>` with your AWS account ID

```bash
eksctl create iamserviceaccount \
  --cluster demo-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

---

## 🔹 8. Install AWS Load Balancer Controller

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

Get VPC ID:

```bash
aws eks describe-cluster \
  --name demo-cluster \
  --region us-east-1 \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text
```

Install controller:

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=demo-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<VPC_ID>
```

---

## 🔹 9. Verify Controller

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

---

## 🔹 10. Deploy Application

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

---

## 🔹 11. Access the Application

```bash
kubectl get ingress -n game-2048
```

Copy the **ADDRESS** and open it in your browser.
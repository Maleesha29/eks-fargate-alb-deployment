#!/bin/bash

CLUSTER_NAME="demo-cluster"
REGION="us-east-1"
ACCOUNT_ID="307946636338"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
ROLE_NAME="AmazonEKSLoadBalancerControllerRole"
VPC_ID="vpc-0b8d0102645c24fb7"

echo "Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --approve

echo "Downloading IAM policy..."
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json

echo "Creating IAM policy..."
aws iam create-policy \
  --policy-name $POLICY_NAME \
  --policy-document file://iam_policy.json

echo "Creating IAM service account..."
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name $ROLE_NAME \
  --attach-policy-arn arn:aws:iam::307946636338:policy/$POLICY_NAME \
  --approve

echo "Adding Helm repo..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

echo "Installing AWS Load Balancer Controller..."
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --set vpcId=$VPC_ID

echo "Verifying deployment..."
kubectl get deployment -n kube-system aws-load-balancer-controller
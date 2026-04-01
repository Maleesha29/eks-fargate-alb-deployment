#!/bin/bash

CLUSTER_NAME="demo-cluster"
REGION="us-east-1"
NAMESPACE="game-2048"

echo "Creating EKS cluster on Fargate..."
eksctl create cluster --name $CLUSTER_NAME --region $REGION --fargate

echo "Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo "Creating Fargate profile for namespace: $NAMESPACE"
eksctl create fargateprofile \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --name alb-sample-app \
  --namespace $NAMESPACE

echo "Cluster and Fargate profile created successfully."
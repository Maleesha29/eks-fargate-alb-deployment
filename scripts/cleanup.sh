#!/bin/bash

CLUSTER_NAME="demo-cluster"
REGION="us-east-1"

echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/ingress.yaml --ignore-not-found
kubectl delete -f k8s/service.yaml --ignore-not-found
kubectl delete -f k8s/deployment.yaml --ignore-not-found
kubectl delete -f k8s/namespace.yaml --ignore-not-found

echo "Deleting EKS cluster..."
eksctl delete cluster --name $CLUSTER_NAME --region $REGION

echo "Cleanup completed."
#!/bin/bash

echo "Deploying namespace..."
kubectl apply -f k8s/namespace.yaml

echo "Deploying application..."
kubectl apply -f k8s/deployment.yaml

echo "Deploying service..."
kubectl apply -f k8s/service.yaml

echo "Deploying ingress..."
kubectl apply -f k8s/ingress.yaml

echo "Checking resources..."
kubectl get all -n game-2048
kubectl get ingress -n game-2048
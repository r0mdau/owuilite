#!/bin/bash

# Kubernetes Deployment Script for OpenWeb UI + LiteLLM
# This script deploys all components to a Kubernetes cluster

set -e

echo "============================================"
echo "OpenWeb UI + LiteLLM Kubernetes Deployment"
echo "============================================"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

# Check if connected to a cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: Not connected to a Kubernetes cluster"
    exit 1
fi

echo "Connected to cluster: $(kubectl config current-context)"
echo ""

# 1. Create namespace
echo "Step 1: Creating namespace..."
kubectl apply -f kubernetes/namespace.yaml
echo "✓ Namespace created"
echo ""

# 2. Deploy infrastructure services
echo "Step 2: Deploying infrastructure services..."
kubectl apply -f kubernetes/postgresql.yaml
kubectl apply -f kubernetes/valkey.yaml
kubectl apply -f kubernetes/minio.yaml
kubectl apply -f kubernetes/qdrant.yaml
echo "✓ Infrastructure services deployed"
echo ""

# 3. Wait for databases to be ready
echo "Step 3: Waiting for databases to be ready..."
echo "Waiting for PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgres -n openwebui --timeout=300s || true
echo "Waiting for Valkey..."
kubectl wait --for=condition=ready pod -l app=valkey -n openwebui --timeout=300s || true
echo "Waiting for Qdrant..."
kubectl wait --for=condition=ready pod -l app=qdrant -n openwebui --timeout=300s || true
echo "✓ Databases are ready"
echo ""

# 4. Deploy application services
echo "Step 4: Deploying application services..."
kubectl apply -f kubernetes/litellm.yaml
kubectl apply -f kubernetes/openwebui.yaml
echo "✓ Application services deployed"
echo ""

# 5. Deploy ingress (optional)
echo "Step 5: Deploying ingress..."
read -p "Do you want to deploy the ingress? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl apply -f kubernetes/ingress.yaml
    echo "✓ Ingress deployed"
else
    echo "⊘ Ingress deployment skipped"
fi
echo ""

# 6. Check status
echo "Step 6: Checking deployment status..."
echo ""
echo "Pods:"
kubectl get pods -n openwebui
echo ""
echo "Services:"
kubectl get svc -n openwebui
echo ""
echo "HPA:"
kubectl get hpa -n openwebui
echo ""

echo "============================================"
echo "Deployment complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Update secrets in kubernetes/litellm.yaml and kubernetes/openwebui.yaml"
echo "2. Configure your domain in kubernetes/ingress.yaml"
echo "3. Monitor the deployment:"
echo "   kubectl get pods -n openwebui -w"
echo "4. Access the UI:"
echo "   kubectl port-forward svc/openwebui 3000:8080 -n openwebui"
echo "   Then open http://localhost:3000"
echo ""

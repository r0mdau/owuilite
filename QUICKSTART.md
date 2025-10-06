# Quick Start Guide

This guide will help you get OpenWeb UI + LiteLLM running in 5 minutes.

## Option 1: Docker Compose (Recommended for Development)

### Step 1: Clone the repository

```bash
git clone https://github.com/r0mdau/owuilite.git
cd owuilite
```

### Step 2: Set up environment variables

```bash
cp .env.example .env
# Edit .env and add your API keys
nano .env
```

### Step 3: Start the services

```bash
docker-compose up -d
```

### Step 4: Access the UI

Open your browser and navigate to:
- **OpenWeb UI**: http://localhost:3000
- **LiteLLM UI**: http://localhost:4000/ui

### Step 5: Create your first user

1. Go to http://localhost:3000
2. Click "Sign Up"
3. Create your admin account (first user is admin)
4. Start chatting!

## Option 2: Kubernetes (Production)

### Prerequisites

- Kubernetes cluster (1.24+)
- kubectl configured
- At least 8GB RAM available
- Storage class configured

### Step 1: Clone the repository

```bash
git clone https://github.com/r0mdau/owuilite.git
cd owuilite
```

### Step 2: Update secrets

Edit the following files and replace placeholder values:
- `kubernetes/litellm.yaml` - Add your API keys
- `kubernetes/openwebui.yaml` - Update database passwords
- `kubernetes/postgresql.yaml` - Set secure passwords
- `kubernetes/ingress.yaml` - Configure your domain

### Step 3: Deploy

```bash
# Make the deploy script executable
chmod +x kubernetes/deploy.sh

# Run the deployment
./kubernetes/deploy.sh
```

### Step 4: Access the UI

```bash
# Port forward to access locally
kubectl port-forward svc/openwebui 3000:8080 -n openwebui

# Then open http://localhost:3000
```

Or configure ingress with your domain and access via HTTPS.

## Troubleshooting

### Docker Compose Issues

**Problem**: Services not starting
```bash
# Check logs
docker-compose logs -f

# Restart services
docker-compose restart
```

**Problem**: Can't connect to LiteLLM
```bash
# Check if LiteLLM is running
docker-compose ps litellm

# Check LiteLLM logs
docker-compose logs litellm
```

### Kubernetes Issues

**Problem**: Pods not starting
```bash
# Check pod status
kubectl get pods -n openwebui

# Describe problematic pod
kubectl describe pod <pod-name> -n openwebui

# Check logs
kubectl logs <pod-name> -n openwebui
```

**Problem**: Database connection issues
```bash
# Check if PostgreSQL is ready
kubectl get pods -l app=postgres -n openwebui

# Test connection
kubectl exec -it postgres-0 -n openwebui -- psql -U openwebui -c "\l"
```

## Next Steps

1. **Configure Models**: Add more LLM providers in `litellm-config.yaml`
2. **Enable RAG**: Upload documents and enable web search
3. **Set Up MCP Servers**: Connect to external tools and data sources
4. **Configure SSO**: Enable enterprise authentication
5. **Monitor**: Set up Prometheus and Grafana for observability

## Useful Commands

### Docker Compose

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]

# Remove all data
docker-compose down -v
```

### Kubernetes

```bash
# Get all resources
kubectl get all -n openwebui

# Watch pods
kubectl get pods -n openwebui -w

# Port forward services
kubectl port-forward svc/openwebui 3000:8080 -n openwebui
kubectl port-forward svc/litellm 4000:4000 -n openwebui

# Scale deployments
kubectl scale deployment openwebui --replicas=5 -n openwebui

# Check HPA status
kubectl get hpa -n openwebui

# View resource usage
kubectl top pods -n openwebui
```

## Getting Help

- Check the [full documentation](README.md)
- Review [example configurations](examples/)
- Open an issue on GitHub
- Join the community Discord

## Security Notes

⚠️ **Important**: Before deploying to production:

1. Change all default passwords
2. Generate secure secret keys
3. Enable HTTPS/TLS
4. Configure firewall rules
5. Enable audit logging
6. Set up regular backups
7. Review and apply security best practices

## License

Apache 2.0 - See [LICENSE](LICENSE) file for details.

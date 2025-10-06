# OpenWeb UI + LiteLLM: From Single Developer to Enterprise Scale

> A comprehensive guide for building and scaling a ChatGPT-like application using OpenWeb UI and LiteLLM
> 
> **Montreal AI Tinkerers Meetup Presentation**

## Table of Contents

1. [Getting Started: Local Development with Docker](#1-getting-started-local-development-with-docker)
2. [LiteLLM Integration for CLI Tools](#2-litellm-integration-for-cli-tools)
3. [Scaling to 1000+ Users with Kubernetes](#3-scaling-to-1000-users-with-kubernetes)
4. [Enterprise Features](#4-enterprise-features)
5. [Additional Resources](#additional-resources)

---

## 1. Getting Started: Local Development with Docker

### Overview

OpenWeb UI is a self-hosted, open-source alternative to ChatGPT that runs entirely on your infrastructure. Combined with LiteLLM, you get a unified interface to 100+ LLMs.

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- API keys for your preferred LLM providers (OpenAI, Anthropic, etc.)

### Quick Start

#### Option A: OpenWeb UI with Ollama (Fully Local)

```bash
# Run OpenWeb UI with bundled Ollama
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Option B: OpenWeb UI with LiteLLM (Cloud LLMs)

**Step 1: Create a docker-compose.yml**

```yaml
version: '3.8'

services:
  litellm:
    image: ghcr.io/berriai/litellm:main-latest
    container_name: litellm
    ports:
      - "4000:4000"
    volumes:
      - ./litellm-config.yaml:/app/config.yaml
    environment:
      - DATABASE_URL=postgresql://llmproxy:dbpassword9090@postgres:5432/litellm
    command: --config /app/config.yaml --port 4000
    depends_on:
      - postgres
    restart: always

  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: litellm
      POSTGRES_USER: llmproxy
      POSTGRES_PASSWORD: dbpassword9090
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: always

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "3000:8080"
    environment:
      - OPENAI_API_BASE_URL=http://litellm:4000/v1
      - OPENAI_API_KEY=sk-1234
      - WEBUI_AUTH=true
    volumes:
      - open-webui-data:/app/backend/data
    depends_on:
      - litellm
    restart: always
    extra_hosts:
      - "host.docker.internal:host-gateway"

volumes:
  postgres-data:
  open-webui-data:
```

**Step 2: Create litellm-config.yaml**

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY
  
  - model_name: gpt-3.5-turbo
    litellm_params:
      model: gpt-3.5-turbo
      api_key: os.environ/OPENAI_API_KEY
  
  - model_name: claude-3-sonnet
    litellm_params:
      model: claude-3-sonnet-20240229
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: gemini-pro
    litellm_params:
      model: gemini/gemini-pro
      api_key: os.environ/GEMINI_API_KEY

litellm_settings:
  drop_params: true
  set_verbose: true
  request_timeout: 600

general_settings:
  master_key: sk-1234
  database_url: postgresql://llmproxy:dbpassword9090@postgres:5432/litellm
```

**Step 3: Set up environment variables**

```bash
# Create .env file
cat > .env << EOF
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
GEMINI_API_KEY=your_gemini_key_here
EOF
```

**Step 4: Launch the stack**

```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f

# Access OpenWeb UI at http://localhost:3000
# Access LiteLLM UI at http://localhost:4000/ui
```

### First Login

1. Navigate to http://localhost:3000
2. Create your admin account (first user becomes admin)
3. Configure models in Settings > Models
4. Start chatting!

### Useful Commands

```bash
# View logs
docker-compose logs -f open-webui
docker-compose logs -f litellm

# Restart services
docker-compose restart

# Stop all services
docker-compose down

# Remove all data (careful!)
docker-compose down -v
```

---

## 2. LiteLLM Integration for CLI Tools

### Overview

LiteLLM provides a unified OpenAI-compatible API for 100+ LLM providers. This allows CLI tools expecting OpenAI's API to work with any LLM.

### LiteLLM Proxy Features

- **Unified Interface**: One API for GPT-4, Claude, Gemini, and more
- **Load Balancing**: Distribute requests across multiple keys/providers
- **Fallback Logic**: Automatically retry failed requests with backup models
- **Cost Tracking**: Monitor spending per user/team
- **Rate Limiting**: Prevent API abuse
- **Caching**: Reduce costs with semantic caching

### Using LiteLLM with CLI Tools

#### Example: Connecting to OpenAI CLI

```bash
# Set LiteLLM as your OpenAI endpoint
export OPENAI_API_BASE=http://localhost:4000/v1
export OPENAI_API_KEY=sk-1234

# Now any OpenAI-compatible CLI tool works
python -c "from openai import OpenAI; client = OpenAI(); print(client.chat.completions.create(model='gpt-4', messages=[{'role': 'user', 'content': 'Hello!'}]))"
```

#### Example: Using with LangChain

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    openai_api_base="http://localhost:4000/v1",
    openai_api_key="sk-1234",
    model="gpt-4"
)

response = llm.invoke("What is the capital of France?")
print(response.content)
```

#### Example: Using with Cursor/Continue IDEs

**Cursor IDE Configuration:**

```json
{
  "openai.apiBase": "http://localhost:4000/v1",
  "openai.apiKey": "sk-1234"
}
```

**Continue IDE Configuration (.continue/config.json):**

```json
{
  "models": [
    {
      "title": "GPT-4 via LiteLLM",
      "provider": "openai",
      "model": "gpt-4",
      "apiBase": "http://localhost:4000/v1",
      "apiKey": "sk-1234"
    }
  ]
}
```

### Advanced LiteLLM Configuration

#### Load Balancing Across Multiple Keys

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY_1
  
  - model_name: gpt-4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY_2
  
  - model_name: gpt-4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY_3

router_settings:
  routing_strategy: least-busy
  num_retries: 3
  timeout: 30
```

#### Fallback Between Providers

```yaml
model_list:
  - model_name: smart-model
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      fallbacks: ["claude-3-sonnet", "gemini-pro"]
  
  - model_name: claude-3-sonnet
    litellm_params:
      model: claude-3-sonnet-20240229
      api_key: os.environ/ANTHROPIC_API_KEY
  
  - model_name: gemini-pro
    litellm_params:
      model: gemini/gemini-pro
      api_key: os.environ/GEMINI_API_KEY

router_settings:
  enable_fallbacks: true
```

#### Semantic Caching to Reduce Costs

```yaml
litellm_settings:
  cache: true
  cache_params:
    type: redis
    host: localhost
    port: 6379
    ttl: 3600  # Cache for 1 hour
    similarity_threshold: 0.8  # 80% similarity
```

---

## 3. Scaling to 1000+ Users with Kubernetes

### Overview

To scale OpenWeb UI from a single developer to 1000+ concurrent users, we need:

- **Horizontal Pod Autoscaling (HPA)**: Auto-scale based on CPU/memory
- **Valkey/Redis**: Session management and caching
- **PostgreSQL**: Persistent user data and conversations
- **MinIO**: S3-compatible object storage for files/images
- **Qdrant**: Vector database for RAG (Retrieval Augmented Generation)

### Architecture Diagram

```
                                 ┌─────────────────┐
                                 │   Ingress/LB    │
                                 └────────┬────────┘
                                          │
                        ┌─────────────────┴─────────────────┐
                        │                                   │
                 ┌──────▼──────┐                   ┌───────▼──────┐
                 │  OpenWeb UI │                   │   LiteLLM    │
                 │   (3+ pods) │                   │  (2+ pods)   │
                 └──────┬──────┘                   └───────┬──────┘
                        │                                  │
        ┌───────────────┼──────────────────────────────────┤
        │               │                                  │
┌───────▼──────┐ ┌─────▼──────┐ ┌──────────┐    ┌────────▼────────┐
│  PostgreSQL  │ │   Valkey   │ │  MinIO   │    │    Qdrant       │
│   (Primary   │ │  (Cache)   │ │ (Files)  │    │   (Vectors)     │
│  + Replica)  │ └────────────┘ └──────────┘    └─────────────────┘
└──────────────┘
```

### Kubernetes Manifests

#### Namespace

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: openwebui
```

#### PostgreSQL with High Availability

```yaml
# postgresql.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  namespace: openwebui
data:
  POSTGRES_DB: openwebui
  POSTGRES_USER: openwebui
---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: openwebui
type: Opaque
stringData:
  POSTGRES_PASSWORD: "changeme_secure_password"
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: openwebui
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:16-alpine
        ports:
        - containerPort: 5432
          name: postgres
        envFrom:
        - configMapRef:
            name: postgres-config
        - secretRef:
            name: postgres-secret
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: openwebui
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
  clusterIP: None
```

#### Valkey (Redis) for Caching

```yaml
# valkey.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: valkey
  namespace: openwebui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: valkey
  template:
    metadata:
      labels:
        app: valkey
    spec:
      containers:
      - name: valkey
        image: valkey/valkey:7-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        volumeMounts:
        - name: valkey-data
          mountPath: /data
      volumes:
      - name: valkey-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: valkey
  namespace: openwebui
spec:
  selector:
    app: valkey
  ports:
  - port: 6379
    targetPort: 6379
```

#### MinIO for Object Storage

```yaml
# minio.yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
  namespace: openwebui
type: Opaque
stringData:
  MINIO_ROOT_USER: "admin"
  MINIO_ROOT_PASSWORD: "changeme_secure_password"
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: minio
  namespace: openwebui
spec:
  serviceName: minio
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        envFrom:
        - secretRef:
            name: minio-secret
        ports:
        - containerPort: 9000
          name: api
        - containerPort: 9001
          name: console
        volumeMounts:
        - name: minio-storage
          mountPath: /data
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
  volumeClaimTemplates:
  - metadata:
      name: minio-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 50Gi
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: openwebui
spec:
  selector:
    app: minio
  ports:
  - name: api
    port: 9000
    targetPort: 9000
  - name: console
    port: 9001
    targetPort: 9001
```

#### Qdrant Vector Database

```yaml
# qdrant.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: qdrant
  namespace: openwebui
spec:
  serviceName: qdrant
  replicas: 1
  selector:
    matchLabels:
      app: qdrant
  template:
    metadata:
      labels:
        app: qdrant
    spec:
      containers:
      - name: qdrant
        image: qdrant/qdrant:latest
        ports:
        - containerPort: 6333
          name: http
        - containerPort: 6334
          name: grpc
        volumeMounts:
        - name: qdrant-storage
          mountPath: /qdrant/storage
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
  volumeClaimTemplates:
  - metadata:
      name: qdrant-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi
---
apiVersion: v1
kind: Service
metadata:
  name: qdrant
  namespace: openwebui
spec:
  selector:
    app: qdrant
  ports:
  - name: http
    port: 6333
    targetPort: 6333
  - name: grpc
    port: 6334
    targetPort: 6334
```

#### LiteLLM Deployment

```yaml
# litellm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: litellm-config
  namespace: openwebui
data:
  config.yaml: |
    model_list:
      - model_name: gpt-4
        litellm_params:
          model: gpt-4
          api_key: os.environ/OPENAI_API_KEY
      
      - model_name: gpt-3.5-turbo
        litellm_params:
          model: gpt-3.5-turbo
          api_key: os.environ/OPENAI_API_KEY
    
    litellm_settings:
      drop_params: true
      set_verbose: false
      request_timeout: 600
      cache: true
      cache_params:
        type: redis
        host: valkey
        port: 6379
    
    general_settings:
      master_key: os.environ/LITELLM_MASTER_KEY
      database_url: os.environ/DATABASE_URL
---
apiVersion: v1
kind: Secret
metadata:
  name: litellm-secret
  namespace: openwebui
type: Opaque
stringData:
  OPENAI_API_KEY: "your_key_here"
  ANTHROPIC_API_KEY: "your_key_here"
  LITELLM_MASTER_KEY: "sk-1234"
  DATABASE_URL: "postgresql://openwebui:changeme_secure_password@postgres:5432/openwebui"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: litellm
  namespace: openwebui
spec:
  replicas: 2
  selector:
    matchLabels:
      app: litellm
  template:
    metadata:
      labels:
        app: litellm
    spec:
      containers:
      - name: litellm
        image: ghcr.io/berriai/litellm:main-latest
        command: ["litellm"]
        args:
        - "--config"
        - "/app/config.yaml"
        - "--port"
        - "4000"
        - "--num_workers"
        - "4"
        ports:
        - containerPort: 4000
          name: http
        envFrom:
        - secretRef:
            name: litellm-secret
        volumeMounts:
        - name: config
          mountPath: /app/config.yaml
          subPath: config.yaml
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: config
        configMap:
          name: litellm-config
---
apiVersion: v1
kind: Service
metadata:
  name: litellm
  namespace: openwebui
spec:
  selector:
    app: litellm
  ports:
  - port: 4000
    targetPort: 4000
```

#### OpenWeb UI with HPA

```yaml
# openwebui.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: openwebui-config
  namespace: openwebui
data:
  OPENAI_API_BASE_URL: "http://litellm:4000/v1"
  ENABLE_RAG_WEB_SEARCH: "true"
  ENABLE_IMAGE_GENERATION: "true"
  QDRANT_URI: "http://qdrant:6333"
  ENABLE_OAUTH_SIGNUP: "true"
  WEBUI_AUTH: "true"
---
apiVersion: v1
kind: Secret
metadata:
  name: openwebui-secret
  namespace: openwebui
type: Opaque
stringData:
  OPENAI_API_KEY: "sk-1234"
  DATABASE_URL: "postgresql://openwebui:changeme_secure_password@postgres:5432/openwebui"
  WEBUI_SECRET_KEY: "changeme_random_secret_key"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openwebui
  namespace: openwebui
spec:
  replicas: 3
  selector:
    matchLabels:
      app: openwebui
  template:
    metadata:
      labels:
        app: openwebui
    spec:
      containers:
      - name: openwebui
        image: ghcr.io/open-webui/open-webui:main
        ports:
        - containerPort: 8080
          name: http
        envFrom:
        - configMapRef:
            name: openwebui-config
        - secretRef:
            name: openwebui-secret
        env:
        - name: DATA_DIR
          value: "/app/backend/data"
        volumeMounts:
        - name: data
          mountPath: /app/backend/data
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
      volumes:
      - name: data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: openwebui
  namespace: openwebui
spec:
  selector:
    app: openwebui
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: openwebui-hpa
  namespace: openwebui
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: openwebui
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 4
        periodSeconds: 30
      selectPolicy: Max
```

#### Ingress

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: openwebui-ingress
  namespace: openwebui
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - openwebui.yourdomain.com
    secretName: openwebui-tls
  rules:
  - host: openwebui.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: openwebui
            port:
              number: 8080
```

### Deployment Steps

```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Deploy infrastructure services
kubectl apply -f postgresql.yaml
kubectl apply -f valkey.yaml
kubectl apply -f minio.yaml
kubectl apply -f qdrant.yaml

# 3. Wait for databases to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n openwebui --timeout=300s
kubectl wait --for=condition=ready pod -l app=valkey -n openwebui --timeout=300s

# 4. Deploy application services
kubectl apply -f litellm.yaml
kubectl apply -f openwebui.yaml

# 5. Deploy ingress
kubectl apply -f ingress.yaml

# 6. Check status
kubectl get pods -n openwebui
kubectl get hpa -n openwebui

# 7. Monitor scaling
watch kubectl get hpa -n openwebui
```

### Monitoring and Observability

```yaml
# prometheus-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: openwebui-metrics
  namespace: openwebui
spec:
  selector:
    matchLabels:
      app: openwebui
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

---

## 4. Enterprise Features

### Overview

Enterprise deployments require additional security, customization, and integration capabilities.

### Single Sign-On (SSO) Integration

#### OAuth2/OIDC Configuration

OpenWeb UI supports OAuth2/OIDC for enterprise SSO integration with providers like:
- Microsoft Entra ID (Azure AD)
- Okta
- Google Workspace
- Keycloak

**Configuration Example (Azure AD):**

```yaml
# In openwebui-config ConfigMap
ENABLE_OAUTH_SIGNUP: "true"
OAUTH_MERGE_ACCOUNTS_BY_EMAIL: "true"
OAUTH_CLIENT_ID: "your_azure_app_id"
OAUTH_CLIENT_SECRET: "your_azure_secret"
OAUTH_PROVIDER_NAME: "Azure AD"
OAUTH_SCOPES: "openid email profile"
OAUTH_AUTHORIZATION_URL: "https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/authorize"
OAUTH_TOKEN_URL: "https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
OAUTH_USERINFO_URL: "https://graph.microsoft.com/oidc/userinfo"
```

#### SAML 2.0 Support

For organizations requiring SAML, use a reverse proxy like:

```yaml
# traefik with SAML plugin
apiVersion: v1
kind: ConfigMap
metadata:
  name: traefik-saml-config
data:
  traefik.yml: |
    entryPoints:
      web:
        address: ":80"
      websecure:
        address: ":443"
    
    providers:
      file:
        filename: /config/dynamic.yml
    
    plugins:
      saml:
        moduleName: github.com/xxx/traefik-saml-plugin
        version: v1.0.0
```

### Custom OpenAPI Models and RAG Systems

#### Integrating Custom Models via LiteLLM

```yaml
# litellm-custom-models.yaml
model_list:
  # Custom fine-tuned GPT model
  - model_name: company-support-bot
    litellm_params:
      model: ft:gpt-3.5-turbo:company-id:custom-model:xxx
      api_key: os.environ/OPENAI_API_KEY
  
  # Self-hosted model via vLLM
  - model_name: internal-llama-70b
    litellm_params:
      model: openai/meta-llama/Llama-2-70b-chat-hf
      api_base: http://vllm-service:8000/v1
      api_key: dummy
  
  # Custom RAG-enhanced model
  - model_name: rag-enhanced-gpt4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY
      custom_llm_provider: openai
    model_info:
      mode: embedding
      base_model: text-embedding-3-large
```

#### RAG Pipeline Configuration

OpenWeb UI includes built-in RAG capabilities with document upload and vector search.

**Qdrant Configuration for RAG:**

```python
# Custom RAG configuration
VECTOR_DB = "qdrant"
QDRANT_URI = "http://qdrant:6333"
CHUNK_SIZE = 1000
CHUNK_OVERLAP = 200
EMBEDDING_MODEL = "text-embedding-3-large"
TOP_K_RESULTS = 5
```

**Document Processing Pipeline:**

```yaml
# openwebui-rag-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: openwebui-rag-config
data:
  RAG_ENABLED: "true"
  VECTOR_DB: "qdrant"
  QDRANT_URI: "http://qdrant:6333"
  CHUNK_SIZE: "1000"
  CHUNK_OVERLAP: "200"
  PDF_EXTRACT_IMAGES: "true"
  ENABLE_RAG_WEB_SEARCH: "true"
  RAG_WEB_SEARCH_ENGINE: "searxng"
  RAG_EMBEDDING_MODEL: "text-embedding-3-large"
  RAG_TEMPLATE: |
    Use the following context to answer the question.
    Context: {context}
    Question: {query}
```

#### Advanced RAG with Multi-Modal Support

```yaml
# Advanced RAG configuration
CONTENT_EXTRACTION_ENGINE: "tika"
ENABLE_RAG_LOCAL_WEB_FETCH: "true"
YOUTUBE_LOADER_LANGUAGE: "en,fr"
RAG_RERANKING_MODEL: "cross-encoder/ms-marco-MiniLM-L-6-v2"
ENABLE_RAG_HYBRID_SEARCH: "true"
```

### Model Context Protocol (MCP) Servers

MCP allows OpenWeb UI to connect to external tools and data sources.

#### Setting Up MCP Servers

**1. File System MCP Server:**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/workspace/projects",
        "/workspace/docs"
      ]
    }
  }
}
```

**2. GitHub MCP Server:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxx"
      }
    }
  }
}
```

**3. PostgreSQL MCP Server:**

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost/db"
      }
    }
  }
}
```

**4. Custom Enterprise MCP Server:**

```javascript
// custom-mcp-server.js
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');

const server = new Server({
  name: 'enterprise-crm',
  version: '1.0.0',
});

// Tool: Query CRM
server.tool('query_crm', 
  'Query customer data from enterprise CRM',
  {
    query: {
      type: 'string',
      description: 'SQL query to execute'
    }
  },
  async ({ query }) => {
    // Connect to enterprise CRM and execute query
    const results = await crmClient.query(query);
    return {
      content: [{ type: 'text', text: JSON.stringify(results, null, 2) }]
    };
  }
);

// Resource: Customer list
server.resource('customers',
  'List of all customers',
  async () => {
    const customers = await crmClient.listCustomers();
    return {
      contents: [{
        uri: 'crm://customers',
        mimeType: 'application/json',
        text: JSON.stringify(customers)
      }]
    };
  }
);

const transport = new StdioServerTransport();
server.connect(transport);
```

#### OpenWeb UI MCP Configuration

```yaml
# openwebui-mcp-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: openwebui-mcp
data:
  mcp-config.json: |
    {
      "mcpServers": {
        "filesystem": {
          "command": "docker",
          "args": [
            "run",
            "-i",
            "--rm",
            "-v", "/workspace:/workspace:ro",
            "mcp/filesystem",
            "/workspace"
          ]
        },
        "github": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-github"],
          "env": {
            "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
          }
        },
        "enterprise-crm": {
          "command": "node",
          "args": ["/mcp-servers/custom-mcp-server.js"],
          "env": {
            "CRM_CONNECTION_STRING": "${CRM_CONNECTION_STRING}"
          }
        }
      }
    }
```

### Permissions and Access Control

#### Role-Based Access Control (RBAC)

OpenWeb UI supports granular permissions:

**User Roles:**
- **Admin**: Full system access
- **User**: Standard user access
- **Pending**: Awaiting approval

**Configuration:**

```yaml
# openwebui-rbac-config.yaml
ENABLE_SIGNUP: "false"  # Disable public signups
ENABLE_LOGIN_FORM: "true"
DEFAULT_USER_ROLE: "pending"  # Require admin approval
ENABLE_COMMUNITY_SHARING: "false"  # Disable public sharing
ENABLE_ADMIN_EXPORT: "true"  # Allow data exports for admins
```

#### Model Access Permissions

```yaml
# Restrict models per user group
MODEL_FILTER_ENABLED: "true"
MODEL_FILTER_LIST: |
  {
    "admin": ["*"],
    "power-user": ["gpt-4", "claude-3-sonnet", "internal-llama-70b"],
    "user": ["gpt-3.5-turbo", "claude-3-haiku"]
  }
```

#### Document Access Control

```python
# Custom document permissions
ENABLE_RAG_WEB_SEARCH: "true"
RAG_DOCUMENT_ACCESS_CONTROL: "true"

# Document tagging for access control
DOCUMENT_TAGS = {
    "public": ["all"],
    "internal": ["user", "power-user", "admin"],
    "confidential": ["power-user", "admin"],
    "secret": ["admin"]
}
```

#### API Key Management

```yaml
# API key configuration for programmatic access
ENABLE_API_KEY: "true"
API_KEY_ALLOWED_IPS: "10.0.0.0/8,172.16.0.0/12"
API_RATE_LIMIT: "100/minute"
```

#### Audit Logging

```yaml
# Comprehensive audit logging
ENABLE_AUDIT_LOG: "true"
AUDIT_LOG_DESTINATION: "syslog://audit-server:514"
AUDIT_LOG_EVENTS: |
  - user_login
  - user_logout
  - model_query
  - document_upload
  - document_access
  - settings_change
  - user_created
  - user_deleted
```

### Enterprise Deployment Checklist

- [ ] **Authentication**
  - [ ] SSO/OIDC configured
  - [ ] MFA enabled
  - [ ] Session timeout configured
  - [ ] Password policy enforced

- [ ] **Authorization**
  - [ ] RBAC implemented
  - [ ] Model access controls
  - [ ] Document permissions
  - [ ] API key management

- [ ] **Security**
  - [ ] TLS/SSL certificates
  - [ ] Network policies
  - [ ] Secrets management (Vault/Sealed Secrets)
  - [ ] Regular security scanning

- [ ] **Data Governance**
  - [ ] Data retention policy
  - [ ] Backup strategy
  - [ ] Disaster recovery plan
  - [ ] Compliance (GDPR, HIPAA, SOC2)

- [ ] **Monitoring**
  - [ ] Application metrics
  - [ ] Infrastructure metrics
  - [ ] Audit logging
  - [ ] Alerting setup

- [ ] **Scalability**
  - [ ] HPA configured
  - [ ] Database replication
  - [ ] Caching layer
  - [ ] CDN for static assets

---

## Additional Resources

### Official Documentation

- [OpenWeb UI Documentation](https://docs.openwebui.com/)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Model Context Protocol](https://modelcontextprotocol.io/)

### Community

- [OpenWeb UI GitHub](https://github.com/open-webui/open-webui)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)
- [Discord Community](https://discord.gg/openwebui)

### Recommended Tools

- **k9s**: Kubernetes cluster management
- **Helm**: Package manager for Kubernetes
- **ArgoCD**: GitOps continuous delivery
- **Prometheus + Grafana**: Monitoring and visualization
- **Loki**: Log aggregation

### Cost Optimization Tips

1. **Use semantic caching** - Reduce LLM API calls by 30-50%
2. **Implement request queuing** - Batch similar requests
3. **Set up fallback models** - Use cheaper models when possible
4. **Monitor token usage** - Track costs per user/team
5. **Use local models** - Ollama for development, vLLM for production

### Security Best Practices

1. **Never commit API keys** - Use secrets management
2. **Enable rate limiting** - Prevent abuse
3. **Implement network policies** - Restrict pod communication
4. **Regular updates** - Keep all components updated
5. **Audit logging** - Track all activities
6. **Data encryption** - At rest and in transit

### Performance Tuning

1. **Database connection pooling** - Use pgBouncer
2. **Redis for session storage** - Reduce database load
3. **CDN for static assets** - Faster page loads
4. **Horizontal scaling** - Add more pods during peak hours
5. **Async processing** - Background jobs for heavy tasks

---

## Quick Reference Commands

```bash
# Docker Compose
docker-compose up -d              # Start all services
docker-compose down               # Stop all services
docker-compose logs -f            # View logs
docker-compose restart            # Restart services

# Kubernetes
kubectl get pods -n openwebui     # List all pods
kubectl logs -f <pod-name> -n openwebui  # View logs
kubectl describe hpa -n openwebui # Check autoscaling
kubectl top pods -n openwebui     # Resource usage

# Database
psql -h localhost -U openwebui -d openwebui  # Connect to PostgreSQL
redis-cli -h localhost            # Connect to Valkey/Redis

# Monitoring
kubectl port-forward svc/openwebui 3000:8080 -n openwebui  # Local access
kubectl port-forward svc/litellm 4000:4000 -n openwebui    # LiteLLM UI
```

---

## Troubleshooting

### Common Issues

**Issue: Pods not starting**
```bash
kubectl describe pod <pod-name> -n openwebui
kubectl logs <pod-name> -n openwebui
```

**Issue: Database connection failed**
```bash
kubectl exec -it <postgres-pod> -n openwebui -- psql -U openwebui
```

**Issue: High memory usage**
```bash
kubectl top pods -n openwebui
# Adjust resource limits in deployment
```

**Issue: Slow response times**
```bash
# Enable caching
# Increase replicas
# Check network latency
kubectl get svc -n openwebui
```

---

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## Support

For questions or issues:
- Open an issue on GitHub
- Join the Discord community
- Check the documentation

---

**Made with ❤️ for the Montreal AI Tinkerers Meetup**

# Montreal AI Tinkerers Meetup Presentation Outline

## Title: Building and Scaling ChatGPT Applications with OpenWeb UI + LiteLLM
### From Single Developer to 1000+ Users

---

## Presentation Structure (45-60 minutes)

### Part 1: Introduction (5 minutes)

**Slide 1: Title Slide**
- Title: Building and Scaling ChatGPT Applications
- Subtitle: OpenWeb UI + LiteLLM Journey
- Speaker info

**Slide 2: The Problem**
- Building ChatGPT-like applications is expensive
- Vendor lock-in with single providers
- Scaling challenges
- Enterprise requirements (SSO, permissions, data privacy)

**Slide 3: The Solution**
- OpenWeb UI: Open-source ChatGPT alternative
- LiteLLM: Unified API for 100+ LLMs
- Self-hosted, full control over data
- Scales from laptop to enterprise

---

### Part 2: Getting Started - Single Developer (10 minutes)

**Slide 4: What is OpenWeb UI?**
- Self-hosted ChatGPT UI
- Document upload and RAG
- Multi-user support
- Extensible with plugins

**Slide 5: What is LiteLLM?**
- Unified API for 100+ LLM providers
- Load balancing and fallbacks
- Cost tracking
- Semantic caching

**Slide 6: Local Setup with Docker**
- Show architecture diagram
- Docker Compose stack
  - OpenWeb UI
  - LiteLLM
  - PostgreSQL
- One command: `docker-compose up -d`

**DEMO 1: Local Setup (3 minutes)**
```bash
# Show the docker-compose.yml
# Run docker-compose up -d
# Access http://localhost:3000
# Create first user (becomes admin)
# Send first message
```

**Slide 7: Key Features for Developers**
- Multiple LLM providers in one place
- Document upload and chat
- Conversation history
- Model switching
- Local and cloud models

---

### Part 3: LiteLLM Integration (10 minutes)

**Slide 8: Why LiteLLM?**
- Single API for all providers
- OpenAI-compatible
- Cost optimization
- Reliability (fallbacks, retries)

**Slide 9: LiteLLM Configuration**
- Show litellm-config.yaml
- Multiple providers (OpenAI, Anthropic, Google)
- Load balancing
- Fallback chains

**Slide 10: Connecting CLI Tools**
- Any OpenAI-compatible tool works
- Examples:
  - LangChain
  - Cursor IDE
  - Continue
  - Custom scripts

**DEMO 2: Using with CLI Tools (3 minutes)**
```bash
# Show litellm-config.yaml
# Export OPENAI_API_BASE=http://localhost:4000/v1
# Run a Python script using OpenAI SDK
# Show request in LiteLLM UI (http://localhost:4000/ui)
# Demonstrate fallback (disable one provider)
```

**Slide 11: Advanced Features**
- Semantic caching (reduce costs by 30-50%)
- Load balancing across keys
- Rate limiting
- Cost tracking per user/team

---

### Part 4: Scaling to 1000+ Users (15 minutes)

**Slide 12: The Scaling Challenge**
- Single Docker instance limitations
- Need for high availability
- Data persistence
- Performance optimization

**Slide 13: Kubernetes Architecture**
- Show comprehensive architecture diagram
- Components:
  - OpenWeb UI pods (HPA)
  - LiteLLM pods
  - PostgreSQL (StatefulSet)
  - Valkey (Redis) for caching
  - MinIO for object storage
  - Qdrant for vector search (RAG)

**Slide 14: Horizontal Pod Autoscaling**
- HPA configuration
- Scale based on CPU/Memory
- Min 3, Max 20 replicas
- Smart scaling policies

**Slide 15: Data Layer**
- PostgreSQL for user data and conversations
- Valkey (Redis) for:
  - Session management
  - LiteLLM caching
  - Rate limiting
- MinIO for file uploads (S3-compatible)
- Qdrant for embeddings and RAG

**DEMO 3: Kubernetes Deployment (5 minutes)**
```bash
# Show kubernetes/ directory structure
# Walk through one manifest (openwebui.yaml)
# Show HPA configuration
# Run deployment script
# Watch pods scaling: kubectl get pods -n openwebui -w
# Show HPA status: kubectl get hpa -n openwebui
```

**Slide 16: Monitoring and Observability**
- Metrics collection (Prometheus)
- Visualization (Grafana)
- Log aggregation (Loki)
- Alerting

**Slide 17: Performance Tuning**
- Database connection pooling
- Redis caching strategy
- CDN for static assets
- Async processing
- Load testing results

---

### Part 5: Enterprise Features (10 minutes)

**Slide 18: Enterprise Requirements**
- Single Sign-On (SSO)
- Fine-grained permissions
- Custom models and RAG
- Integration with existing tools
- Compliance (GDPR, HIPAA, SOC2)

**Slide 19: Authentication & Authorization**
- SSO support:
  - Azure AD / Microsoft Entra ID
  - Google Workspace
  - Okta
  - Keycloak
- RBAC (Role-Based Access Control)
- Model access restrictions
- Document permissions

**Slide 20: Custom Models via LiteLLM**
- Fine-tuned models
- Self-hosted models (vLLM, Ollama)
- Custom routing and fallbacks
- Team-based access control

**DEMO 4: SSO & Permissions (3 minutes)**
```bash
# Show openwebui-enterprise.env
# Demonstrate OAuth configuration
# Show model filtering by role
# Show team-based budgets in LiteLLM
```

**Slide 21: RAG (Retrieval Augmented Generation)**
- Document upload and processing
- Vector search with Qdrant
- Web search integration
- Custom knowledge bases
- Multi-modal support

**Slide 22: Model Context Protocol (MCP)**
- What is MCP?
- Connect to external systems:
  - File systems
  - GitHub
  - Databases
  - Slack
  - Custom enterprise tools
- Show custom MCP server example

**DEMO 5: MCP Integration (2 minutes)**
```bash
# Show mcp-config.json
# Demonstrate file system MCP
# Demonstrate GitHub MCP
# Show custom enterprise MCP server code
```

**Slide 23: Security Best Practices**
- TLS/SSL everywhere
- Secrets management (Vault, Sealed Secrets)
- Network policies
- Regular security scans
- Audit logging
- Data encryption at rest and in transit

---

### Part 6: Real-World Use Cases (5 minutes)

**Slide 24: Use Case 1 - Customer Support**
- Custom fine-tuned support bot
- Integration with CRM via MCP
- Automatic ticket creation
- Knowledge base RAG

**Slide 25: Use Case 2 - Internal Developer Tools**
- Code assistance with GitHub integration
- Documentation search
- API reference lookup
- Local code execution

**Slide 26: Use Case 3 - Data Analysis**
- SQL generation via database MCP
- Data visualization
- Report generation
- Multi-model analysis

**Slide 27: Use Case 4 - Content Generation**
- Marketing copy generation
- Image generation (Stable Diffusion)
- Multi-language support
- Brand consistency via custom models

---

### Part 7: Cost Analysis & Optimization (5 minutes)

**Slide 28: Cost Breakdown**
- Infrastructure costs (Kubernetes)
- LLM API costs
- Storage costs
- Comparison with ChatGPT Enterprise

**Slide 29: Cost Optimization Strategies**
- Semantic caching (30-50% savings)
- Smart routing (use cheaper models when possible)
- Batch processing
- Usage monitoring and budgets
- Local models for non-sensitive tasks

**Slide 30: ROI Analysis**
- Break-even point
- Scalability benefits
- Data ownership value
- Customization advantages

---

### Part 8: Q&A and Resources (5 minutes)

**Slide 31: Getting Started**
- Repository: github.com/r0mdau/owuilite
- Quick start: 5-minute Docker setup
- Full documentation
- Example configurations

**Slide 32: Community Resources**
- OpenWeb UI GitHub
- LiteLLM GitHub
- Discord communities
- Documentation sites

**Slide 33: Next Steps**
- Clone the repository
- Try local setup
- Explore examples
- Deploy to staging
- Join the community

**Slide 34: Thank You & Questions**
- Contact information
- Repository link
- Q&A session

---

## Demo Environment Setup

### Before Presentation
1. Have Docker Compose stack running
2. Kubernetes cluster ready (can be local with kind/minikube)
3. Pre-loaded test data
4. Multiple browser tabs open:
   - OpenWeb UI (localhost:3000)
   - LiteLLM UI (localhost:4000/ui)
   - Kubernetes dashboard
   - Grafana (if available)

### Demo Scripts

**Demo 1: Local Setup**
```bash
cd owuilite
code docker-compose.yml  # Show configuration
docker-compose up -d
docker-compose logs -f  # Show startup
# Open http://localhost:3000
# Create admin user
# Send test message
```

**Demo 2: CLI Integration**
```bash
export OPENAI_API_BASE=http://localhost:4000/v1
export OPENAI_API_KEY=sk-1234
python demo_script.py  # Uses OpenAI SDK
# Show request in LiteLLM UI
```

**Demo 3: Kubernetes**
```bash
cd kubernetes
cat openwebui.yaml  # Show HPA config
./deploy.sh
kubectl get pods -n openwebui -w
kubectl get hpa -n openwebui
kubectl top pods -n openwebui
```

**Demo 4: Enterprise Features**
```bash
cat examples/openwebui-enterprise.env  # Show SSO config
cat examples/litellm-advanced-config.yaml  # Show team budgets
# Show UI with multiple users/roles
```

**Demo 5: MCP**
```bash
cat examples/mcp-config.json
cat examples/custom-mcp-server.js
# Show MCP working in OpenWeb UI
```

---

## Presentation Tips

1. **Start with the problem**: Everyone knows ChatGPT is expensive and limited
2. **Show, don't just tell**: Live demos are crucial
3. **Keep it practical**: Focus on real-world use cases
4. **Be honest about limitations**: Acknowledge what's hard
5. **Encourage experimentation**: Repository is ready to clone and try

## Backup Plans

1. If live demos fail, have screenshots/videos ready
2. If Kubernetes demo is too complex, stick with Docker
3. If time is short, prioritize sections 1-3
4. Have pre-recorded demos as backup

## Handouts/Resources

- QR code to GitHub repository
- One-page quick start guide
- Architecture diagrams
- Cost comparison sheet
- Contact information for follow-up

---

## Post-Presentation

1. Upload slides to repository
2. Share demo videos
3. Answer questions on Discord/GitHub
4. Blog post with detailed walkthrough
5. Follow-up presentation on advanced topics

---

## Estimated Timeline

- Introduction: 5 min
- Part 1 (Single Dev): 10 min
- Part 2 (LiteLLM): 10 min
- Part 3 (Scaling): 15 min
- Part 4 (Enterprise): 10 min
- Part 5 (Use Cases): 5 min
- Part 6 (Cost): 5 min
- Q&A: 5 min
- **Total: 65 minutes** (adjust based on available time)

## Key Takeaways for Audience

1. ✅ Can deploy ChatGPT-like app in 5 minutes with Docker
2. ✅ LiteLLM provides unified API for all LLM providers
3. ✅ Scales from laptop to 1000+ users with Kubernetes
4. ✅ Enterprise features: SSO, permissions, custom models, MCP
5. ✅ 30-50% cost savings with semantic caching
6. ✅ Full data ownership and control
7. ✅ Open source and community-driven

---

**Repository**: https://github.com/r0mdau/owuilite

**Made with ❤️ for the Montreal AI Tinkerers Meetup**

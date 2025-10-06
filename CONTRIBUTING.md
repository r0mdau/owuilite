# Contributing to owuilite

Thank you for your interest in contributing to the OpenWeb UI + LiteLLM guide!

## How to Contribute

We welcome contributions from the community! Here are some ways you can help:

### 1. Documentation Improvements

- Fix typos or unclear explanations
- Add missing information
- Improve code examples
- Translate documentation to other languages
- Add more use case examples

### 2. Configuration Examples

- Share your production configurations (with sensitive data removed)
- Add examples for different cloud providers (AWS, GCP, Azure)
- Contribute Docker Compose variations
- Share Kubernetes optimizations

### 3. Tools and Scripts

- Add deployment automation scripts
- Create monitoring dashboards
- Build testing utilities
- Share migration tools

### 4. Real-World Use Cases

- Document your deployment experience
- Share performance benchmarks
- Contribute case studies
- Add troubleshooting guides

## Getting Started

### Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/owuilite.git
cd owuilite

# Add upstream remote
git remote add upstream https://github.com/r0mdau/owuilite.git
```

### Create a Branch

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or for documentation fixes
git checkout -b docs/your-fix-description
```

### Make Your Changes

1. Follow the existing documentation style
2. Test any code examples you add
3. Ensure YAML files are valid
4. Add comments where helpful

### Test Your Changes

```bash
# For Docker Compose changes
docker-compose config  # Validate syntax
docker-compose up -d   # Test deployment

# For Kubernetes manifests
kubectl apply --dry-run=client -f kubernetes/
kubectl apply --dry-run=server -f kubernetes/
```

### Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a clear message
git commit -m "Add: description of your changes"

# Examples:
# git commit -m "Add: Azure AD SSO configuration example"
# git commit -m "Fix: typo in Kubernetes deployment guide"
# git commit -m "Docs: improve MCP server explanation"
```

### Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Go to GitHub and create a Pull Request
```

## Pull Request Guidelines

### PR Title Format

- **Add**: New features, examples, or documentation
- **Fix**: Bug fixes or corrections
- **Update**: Updates to existing content
- **Docs**: Documentation improvements
- **Refactor**: Code restructuring without changing behavior

Examples:
- `Add: Terraform configuration for AWS deployment`
- `Fix: incorrect PostgreSQL connection string in example`
- `Update: LiteLLM to version 1.x configuration`
- `Docs: clarify HPA scaling behavior`

### PR Description

Include:
1. **What**: Brief description of changes
2. **Why**: Reason for the changes
3. **How**: Approach taken (if not obvious)
4. **Testing**: How you tested the changes
5. **Screenshots**: For UI or visual changes

Example:
```markdown
## What
Added Azure Kubernetes Service (AKS) deployment guide

## Why
Many users deploy on AKS and need specific configurations

## How
- Created new AKS-specific manifests
- Added storage class for Azure Disk
- Documented Azure AD integration

## Testing
- Deployed on AKS cluster
- Verified all pods running
- Tested SSO with Azure AD
- Confirmed persistent storage

## Screenshots
[Include if applicable]
```

### Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. You'll be credited in the commit

## Documentation Style Guide

### Markdown Formatting

- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language specification
- Use relative links for internal references
- Keep line length reasonable (80-120 characters when possible)

### Code Examples

```yaml
# Good: Include comments explaining non-obvious parts
apiVersion: v1
kind: Service
metadata:
  name: openwebui
  namespace: openwebui
  annotations:
    # This annotation enables internal load balancing
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
```

### Command Examples

```bash
# Good: Include context and expected output
kubectl get pods -n openwebui
# Expected output:
# NAME                         READY   STATUS    RESTARTS   AGE
# openwebui-7d5b9c4f6d-abc12   1/1     Running   0          5m
```

## Areas We Need Help

### High Priority

- [ ] Helm charts for Kubernetes deployment
- [ ] Terraform modules for cloud deployments
- [ ] Ansible playbooks for automated setup
- [ ] Performance benchmarking tools
- [ ] Cost optimization guides for different providers
- [ ] Migration guides from ChatGPT/other platforms

### Documentation Needed

- [ ] Troubleshooting common issues
- [ ] Backup and disaster recovery procedures
- [ ] Upgrade procedures
- [ ] Multi-region deployment guide
- [ ] Monitoring and alerting setup
- [ ] Security hardening checklist

### Examples Wanted

- [ ] Production configurations (anonymized)
- [ ] Load testing results
- [ ] Cost breakdowns
- [ ] Integration with other tools (CI/CD, etc.)
- [ ] Custom MCP servers for popular services

## Code of Conduct

### Be Respectful

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what's best for the community

### Be Collaborative

- Help others learn and grow
- Share knowledge freely
- Credit others for their contributions
- Assume good intentions

### Be Professional

- Keep discussions on-topic
- Avoid spam and self-promotion
- Don't share sensitive information
- Follow the repository rules

## Questions?

- Open a GitHub Issue for questions about contributing
- Join the community Discord for real-time chat
- Email the maintainers for private concerns

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0, the same license as the project.

## Recognition

Contributors will be:
- Listed in the repository
- Credited in commit messages
- Mentioned in release notes (for significant contributions)

## Thank You!

Every contribution, no matter how small, helps make this project better for everyone. We appreciate your time and effort!

---

**Happy Contributing! 🚀**

# Jenkins GitOps

**Repository:** https://github.com/lfit/jenkins-gitops

GitOps-driven Jenkins deployment on Kubernetes using ArgoCD, Helm, and Jenkins Configuration as Code (JCasC).

## What is jenkins-gitops?

This repository implements a declarative, GitOps-based deployment system for Jenkins CI/CD infrastructure. All Jenkins configuration—from system settings to plugin versions to build agent definitions—is stored as code in Git. Changes automatically trigger validation workflows and propagate through ArgoCD to Kubernetes clusters.

Git serves as the single source of truth. Manual cluster changes are automatically reverted, and all infrastructure modifications go through pull requests with automated validation.

## Key Capabilities

- **Declarative Configuration**: Everything defined as code using Helm charts and JCasC YAML
- **Automated Validation**: Helm linting, security scanning, and schema validation on every pull request
- **Multi-Environment Deployments**: Separate staging and production environments with progressive delivery
- **Secrets Management**: External secret management via External Secrets Operator
- **GitOps Workflow**: ArgoCD automatically syncs Git state to Kubernetes clusters
- **App-of-Apps Pattern**: Single root Application manages all environment Applications
- **Zero Manual Configuration**: Jenkins settings managed entirely through JCasC

## Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| [Architecture](docs/ARCHITECTURE.md) | System architecture, components, design patterns, and security | Engineers, Architects |
| [Deployment](docs/DEPLOYMENT.md) | Deployment procedures, workflows, monitoring, and troubleshooting | Release Engineers, SRE |
| [Configuration](docs/CONFIGURATION.md) | Configuration hierarchy, Helm values, and JCasC integration | Engineers, Operators |

## Repository Structure

```
jenkins-gitops/
├── root-app.yaml              # ArgoCD root Application (entry point)
├── argocd-apps/               # ArgoCD Application definitions
├── base/jenkins/              # Base Helm chart and JCasC configuration
├── build/                     # Docker image build (Dockerfile, plugins.txt)
├── staging/                   # Staging environment overrides
├── production/                # Production environment overrides
└── docs/                      # Documentation
```

## Technology Stack

- **ArgoCD**: GitOps continuous delivery
- **Kubernetes**: Container orchestration platform
- **Helm**: Package management and templating
- **Jenkins Configuration as Code (JCasC)**: Declarative Jenkins configuration
- **External Secrets Operator**: External secret management integration

## Support

For issues, questions, or support requests, open a ticket at [support.linuxfoundation.org](https://support.linuxfoundation.org).

## Project Status

This project is actively maintained by the Linux Foundation Release Engineering team.

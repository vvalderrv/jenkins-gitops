# Jenkins GitOps Deployment

This repository provides a fully declarative Jenkins deployment architecture leveraging GitOps principles. It integrates Helm for templated configuration, ArgoCD for continuous delivery, and Jenkins Configuration as Code (JCasC) to ensure reproducible, version-controlled controller setup.

All aspects of the Jenkins deployment—including plugins, UI settings, global configuration, and controller image—are defined and managed in Git, enabling consistent promotion across development, staging, and production environments.

## Tools and Architecture

This deployment integrates the following components to manage Jenkins using GitOps principles.

### Helm
Used to template and render Kubernetes manifests, including Jenkins Configuration as Code (JCasC). The base chart is located in `base/jenkins/`, and each environment (dev, staging, production) provides its own Helm values file to override behavior.

### Jenkins Configuration as Code (JCasC)
Provides a complete, declarative configuration for the Jenkins controller. YAML files in `base/jenkins/jcasc_yamls/` are rendered into a Kubernetes ConfigMap via Helm and mounted into the controller container. Environment-specific values are injected using environment variables defined in each environment's `values.yaml`.

### Git
Serves as the single source of truth for all configuration. This includes JCasC files, Helm values, ArgoCD manifests, and plugin versions. Changes are proposed through pull requests and applied through ArgoCD synchronization.

### ArgoCD
Continuously applies the desired state of Jenkins based on Git. Each environment is defined by an ArgoCD Application, which points to the base chart and its corresponding values file. Changes are automatically applied through Git commits and GitOps synchronization.

### Docker
Used to build a custom Jenkins controller image with pinned plugins. The Dockerfile is located in `build/`, and the plugin list is defined in `plugins.txt`. This ensures consistent behavior across environments and supports reproducible upgrades.

## Repository Structure

This repository organizes configuration and deployment logic into the following logical components:

```
jenkins-gitops/
├── argocd-apps/              # ArgoCD Application and Project definitions
│   ├── jenkins-project.yaml          # Defines ArgoCD project scope
│   └── jenkins-dev-app.yaml          # Maps dev values into base chart
├── base/jenkins/             # Jenkins Helm chart and JCasC bundle
│   ├── jcasc_yamls/                  # Modular JCasC YAMLs (systemMessage, agents, etc.)
│   └── templates/                    # Helm templates (ConfigMap rendering, helpers)
├── dev/                      # Development environment overrides
│   └── values.yaml                   # Dev-specific Helm values and JCasC variables
├── staging/                  # Staging overrides (same structure)
├── production/               # Production overrides (same structure)
├── build/                    # Jenkins Docker image builder
│   ├── Dockerfile                   # Builds Jenkins with pinned plugins
│   └── plugins.txt                  # Plugin list with version pins
```

## JCasC Integration

Jenkins is configured using Configuration as Code (JCasC). This repository defines all controller-level configuration as modular YAML files stored in `base/jenkins/jcasc_yamls/`.

These files are bundled into a Kubernetes ConfigMap by the Helm chart. The chart template `jcasc-configmap.yaml` includes the following logic:

```yaml
{{- $files := .Files.Glob "jcasc_yamls/*.yaml" }}
{{- range $path, $_ := $files }}
  {{ base $path }}: |-
{{ ($.Files.Get $path | toString) | indent 4 }}
{{- end }}
```

Each YAML file becomes a separate key in the ConfigMap. This ConfigMap is then mounted into the Jenkins controller pod using the following Helm values:

```yaml
controller:
  containerEnv:
    - name: CASC_JENKINS_CONFIG
      value: "/var/jenkins_home/casc_config/"
  extraVolumes:
    - name: jcasc-config
      configMap:
        name: "jenkins-jcasc-config"
  extraVolumeMounts:
    - name: jcasc-config
      mountPath: "/var/jenkins_home/casc_config/"
```

At runtime, Jenkins reads and applies all YAML files in the `casc_config` directory. Any environment-specific configuration is injected via environment variables defined in the corresponding environment's `values.yaml`.

## Environment Configuration

This repository supports multiple deployment environments (development, staging, production) using environment-specific Helm values.

Each environment directory contains a `values.yaml` file:

- `dev/values.yaml`
- `staging/values.yaml`
- `production/values.yaml`

These files override configuration defined in the base Helm chart. Typical overrides include:

- Jenkins controller image and tag
- JVM options or resource limits
- JCasC-related environment variables (e.g., `JCASC_SYSTEM_MESSAGE`, `JCASC_LOCATION_ADMINADDRESS`)

These environment variables are passed into the Jenkins container and used in the JCasC YAMLs via `${}` interpolation.

Only one set of JCasC YAMLs is used across all environments (`base/jenkins/jcasc_yamls/`). Per-environment JCasC files are not currently supported and should not be added without modifying the Helm chart to explicitly render them.

## Plugin Management

Jenkins plugins are installed through a custom Docker image built from the `build/` directory. Plugin versions are explicitly pinned to ensure consistency across environments.

### Plugin Pinning

The file `build/plugins.txt` defines the complete plugin set and exact versions. For example:

```
git:5.2.1
workflow-aggregator:596.v8c21c963d92d
```

This list is consumed by the `jenkins-plugin-cli` tool during the image build.

### Updating Plugins

To change or upgrade plugins:

1. Edit `build/plugins.txt`
2. Rebuild the Docker image using the `build/` directory
3. Push the updated image to your container registry
4. Update the image tag in the appropriate `values.yaml` (e.g., `dev/values.yaml`)
5. ArgoCD will detect the change and redeploy Jenkins

Plugin changes are controlled entirely through Git and applied via GitOps. Manual plugin installation in the Jenkins UI is not supported or recommended.

## Continuous Integration

A GitHub Actions pipeline will be added to validate Helm templates and enforce repository standards. Linting, schema validation, and plugin diff checks may be included in a future release.

## GitOps Promotion Workflow

This repository supports a multi-environment GitOps promotion model based on ArgoCD and Git pull requests.

1. Submit a pull request that modifies `dev/values.yaml` or JCasC base configuration
2. ArgoCD will sync the `jenkins-dev` namespace with the updated configuration
3. Once verified in development, promote changes to `staging/values.yaml` through a second pull request
4. ArgoCD will sync the `jenkins-staging` namespace with the staging configuration
5. After validation in staging, promote to `production/values.yaml` via pull request
6. ArgoCD will apply the changes to the `jenkins-prod` namespace

## Support

For assistance, please open a ticket at https://support.linuxfoundation.org

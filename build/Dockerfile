FROM jenkins/jenkins:2.492.3-lts-jdk21

# Set maintainer and disable setup wizard
LABEL maintainer="OpenSearch Staging Environment"
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Copy the plugins.txt file
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Switch to root for installations
USER root

# Install system packages and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    python3 \
    python3-pip \
    python3-dev \
    zip \
    unzip \
    build-essential \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (for containerized builds)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages used by OpenSearch
RUN pip3 install --no-cache-dir --break-system-packages \
    boto3 \
    pyyaml \
    requests==2.32.0 \
    docker==6.1.3 \
    packaging==24.1 \
    pipenv \
    awscli

# Install Node.js 18.x and global npm packages (system-wide installation)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g fs-extra chalk@4.1.2 aws-cdk cdk-assume-role-credential-plugin@1.4.0 \
    && rm -rf /var/lib/apt/lists/*

# Install 1Password CLI using main branch
RUN curl -SfL https://raw.githubusercontent.com/opensearch-project/opensearch-build/main/docker/ci/config/op-setup.sh -o op-setup.sh && \
    bash op-setup.sh && \
    rm -v op-setup.sh

# Create jenkins directories with proper permissions
RUN mkdir -p /var/jenkins && chown -R jenkins:jenkins /var/jenkins

# Switch back to jenkins user
USER jenkins

# Install Jenkins plugins
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

# Verify installations work
RUN aws --version && \
    docker --version && \
    gh --version && \
    op --version && \
    node --version && \
    npm --version && \
    python3 --version && \
    pip3 --version

FROM jenkins/jenkins:2.492.3-lts-jdk21

# Set maintainer and disable setup wizard
LABEL maintainer="OpenSearch Staging Environment"
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Copy the plugins.txt file
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Switch to root only for essential system package installations
USER root

# Install system packages with security best practices
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    jq \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    zip \
    unzip \
    build-essential \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

# Install Docker CLI with GPG verification
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install GitHub CLI with GPG verification
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Node.js 18.x (maintained as root for system-wide installation)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install global npm packages as root (for system-wide access)
RUN npm install -g fs-extra chalk@4.1.2 aws-cdk cdk-assume-role-credential-plugin@1.4.0

# Create jenkins directories with proper permissions while root
RUN mkdir -p /var/jenkins /home/jenkins/.local /home/jenkins/.local/bin \
    && chown -R jenkins:jenkins /var/jenkins /home/jenkins/.local

# Switch to jenkins user as early as possible
USER jenkins

# Install Python packages as jenkins user with venv
RUN python3 -m venv /home/jenkins/.local/venv \
    && /home/jenkins/.local/venv/bin/pip install --no-cache-dir \
    boto3 \
    pyyaml \
    requests==2.32.0 \
    docker==6.1.3 \
    packaging==24.1 \
    pipenv \
    awscli

# Add virtual environment to PATH for Python packages
ENV PATH="/home/jenkins/.local/venv/bin:/home/jenkins/.local/bin:${PATH}"

# Install 1Password CLI (requires root temporarily)
USER root
RUN curl -SfL https://raw.githubusercontent.com/opensearch-project/opensearch-build/main/docker/ci/config/op-setup.sh -o op-setup.sh \
    && bash op-setup.sh \
    && rm -v op-setup.sh \
    && chown jenkins:jenkins /usr/local/bin/op 2>/dev/null || true

# Return to jenkins user immediately after privileged operation
USER jenkins

# Install Jenkins plugins as jenkins user
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

# Use a Jenkins LTS (Long Term Support) image as the base
FROM jenkins/jenkins:lts-jdk17

# Switch to root user to install plugins and tools
USER root

# Copy the plugins.txt file into the Jenkins image
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Install plugins using the jenkins-plugin-cli tool
# This avoids issues with finding/executing install-plugins.sh
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

# Add any other tools or configurations needed for your Jenkins master image here
# For example:
# RUN apt-get update && apt-get install -y \
#    python3 \
#    python3-pip \
#    jq \
#    yq \
#    && rm -rf /var/lib/apt/lists/*
# RUN pip3 install jenkins-job-builder lftools

# Switch back to the jenkins user
USER jenkins

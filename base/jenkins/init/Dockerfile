FROM jenkins/jenkins:lts

USER root

RUN mkdir -p /usr/share/jenkins/ref/bin

COPY entrypoint.sh /usr/share/jenkins/ref/bin/entrypoint.sh
COPY plugin-entrypoint.sh /usr/share/jenkins/ref/bin/plugin-entrypoint.sh

RUN chmod +x /usr/share/jenkins/ref/bin/entrypoint.sh \
    && chmod +x /usr/share/jenkins/ref/bin/plugin-entrypoint.sh

USER jenkins

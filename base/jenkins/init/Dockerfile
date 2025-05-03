# InitContainer image to inject JCasC configs into Jenkins PVC

FROM alpine:3.18

LABEL maintainer="LFIT"
LABEL description="InitContainer for injecting JCasC configs into Jenkins"

# Install bash for scripting
RUN apk add --no-cache bash

# Copy entrypoint and config files
COPY ./base/jenkins/init/entrypoint.sh /entrypoint.sh
COPY ./base/jenkins/init/jcasc /jcasc/

# Execute entrypoint on container start
ENTRYPOINT ["/entrypoint.sh"]

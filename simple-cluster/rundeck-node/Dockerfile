ARG RUNDECK_IMAGE
FROM ${RUNDECK_IMAGE}

USER root

#Create logs dir path
RUN mkdir -p /home/rundeck/var/logs && \
    chown rundeck:root /home/rundeck/var/logs
    
# Set output log dir as volume so it can be shared across containers
USER rundeck
VOLUME /home/rundeck/var/logs

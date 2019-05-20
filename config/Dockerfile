ARG RUNDECK_IMAGE

FROM ${RUNDECK_IMAGE:-rundeck/rundeck:SNAPSHOT}

ADD --chown=rundeck:root https://github.com/rundeck-plugins/http-tours/releases/download/v0.1.0/http-tours-0.1.0.jar ./libext/

COPY --chown=rundeck:root remco /etc/remco

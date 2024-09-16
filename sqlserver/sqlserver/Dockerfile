FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Bundle app source
COPY . /usr/src/app

# Grant permissions for the import-data script to be executable
RUN chmod +x /usr/src/app/import-data.sh

USER mssql
CMD /bin/bash ./entrypoint.sh
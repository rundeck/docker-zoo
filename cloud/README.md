Cloud Exhibit
=============
This exhibit demonstrates what a typical cloud or multi-server
deployment may look like.

On display:
* Storage backend connected to a database server
* Execution logs stored in S3
* Bundling extra plugins


## Setup
**Fetch S3 log plugin**
```
mkdir libext
cd libext
wget https://github.com/rundeck-plugins/rundeck-s3-log-plugin/releases/download/v1.0.5/rundeck-s3-log-plugin-1.0.5.jar
```

**Populate `.env` file**

`docker-compose up`
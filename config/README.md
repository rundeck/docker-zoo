Configurations Exhibit
=============
This exhibit demonstrates how to extend the configuration with settings
not included in the base Rundeck docker images.

On display:
* Adding new configuration templates
* Bundling plugins

### Configuration
Extending the configuration involves adding new [Remco](https://github.com/HeavyHorst/remco)
resources and templates. These are copied into the derived image
and get combined into `framework.properties` and `rundeck-config.properties`
during startup.

Destinations:  
**framework.properties**  
```
${REMCO_TMP_DIR}/framework/<name>
```
**rundeck-config.properties**  
```
${REMCO_TMP_DIR}/rundeck-config/
```

## Setup
**Build and Up**  
> **NOTE:** Building is not necessary the first time, however
it will be to use newer or different images after the
first build.
```
docker-compose build
docker-compose up
```

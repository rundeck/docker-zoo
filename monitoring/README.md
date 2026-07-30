Monitoring / Observability
==========================

A minimal, runnable observability stack for Rundeck: **metrics** with Prometheus,
**logs** with Loki, and **Grafana** to visualize both.

- **Metrics** — Prometheus scrapes Rundeck's native `/monitoring/prometheus` endpoint
  (Rundeck 6+; no third-party exporter needed).
- **Logs** — container stdout/stderr reach Loki via the **Docker Loki logging driver**.
  No OpenTelemetry Collector, no Promtail, no access to the Docker socket — Docker itself
  routes the logs.
- **Grafana** — the Prometheus and Loki datasources are auto-provisioned.

```
  Rundeck ─/monitoring/prometheus→ Prometheus ┐
  Rundeck ─(Docker loki log driver)→ Loki ────┼─→ Grafana (:3000)
```

This exhibit accompanies the docs.rundeck.com how-tos
[Monitor the Rundeck Server with Prometheus and Grafana](https://docs.rundeck.com/docs/learning/howto/monitor-server-grafana.html)
and [Monitor a Runner with Prometheus and Grafana](https://docs.rundeck.com/docs/learning/howto/monitor-runner-grafana.html).

## Prerequisite: the Loki Docker logging driver

Install the plugin on the host once:

```bash
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
docker plugin ls | grep loki   # ENABLED should be "true"
```

## Run

```bash
docker compose up -d
```

- Grafana:    http://localhost:3000  (anonymous admin, no login)
- Rundeck:    http://localhost:4440  (default `admin` / `admin`)
- Prometheus: http://localhost:9090
- Loki API:   http://localhost:3100

Override the image with `RUNDECK_IMAGE=rundeck/rundeck:<tag> docker compose up -d`.

## Verify

Metrics target is UP:

```bash
curl -s 'http://localhost:9090/api/v1/targets' | grep -o '"health":"[a-z]*"'
```

Container logs are reaching Loki (returns the service labels the driver attaches):

```bash
curl -s 'http://localhost:3100/loki/api/v1/label/compose_service/values'
# -> {"status":"success","data":["prometheus","rundeck"]}
```

In Grafana:

- **Explore → Loki**, query `{compose_service="rundeck"}` to stream Rundeck's logs.
- **Explore → Prometheus**, query `jvm_memory_used_bytes` to confirm metrics.
- **Drilldown → Logs** (the "Logs Drilldown" app) lists services visually — enabled by
  `limits_config.volume_enabled: true` in `loki/loki-config.yml`.

## Dashboards

Two dashboards are auto-provisioned into the **Rundeck** folder in Grafana (via
`grafana/provisioning/dashboards/dashboards.yml`, which loads the JSON files mounted at
`/var/lib/grafana/dashboards`):

- **Rundeck Overview** (`grafana/dashboards/Rundeck-Overview.json`) — JVM, HTTP, scheduler,
  cache, and execution metrics from `/monitoring/prometheus`.
- **Runner Dashboard** (`grafana/dashboards/Runner-Dashboard.json`) — the Runner operation and
  report-delivery metrics produced by the JMX exporter mapping in `runner-agent/jmx-config.yml`.

Both bind to the `prometheus` datasource. Some panels only populate when their source is present:
the Runner dashboard needs a Runner scraped via `runner-agent/jmx-config.yml`, and a few Rundeck
panels depend on business metrics that are exposed on certain Rundeck distributions — panels with
no matching series simply render empty.

## Monitoring a Runner

A Runner has no HTTP metrics endpoint; its metrics are JMX MBeans. Run the
[Prometheus JMX Exporter](https://github.com/prometheus/jmx_exporter) in-process and point
it at `runner-agent/jmx-config.yml` (included here), which maps the Runner's Micrometer JMX
beans to the Prometheus series the Runner dashboard expects:

```bash
java \
  -javaagent:/path/to/jmx_prometheus_javaagent.jar=9404:/path/to/jmx-config.yml \
  -jar pd-runner.jar
```

Then add a scrape target for `<runner-host>:9404` to `prometheus/prometheus.yml`, and route the
Runner container's logs to Loki with the same `logging:` block used by the services above. See the
[runner how-to](https://docs.rundeck.com/docs/learning/howto/monitor-runner-grafana.html) for the
full walkthrough.

## Tear down

```bash
docker compose down -v
```

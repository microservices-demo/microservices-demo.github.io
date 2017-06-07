---
layout: default
deployDoc: true
---

## Docker Compose

> NOTE: All the commands listed on this guide must be ran from the root of the project.


To deploy Prometheus & Grafana and to setup all the nice graphs that we got ready
for you, simply:

```
$ docker-compose -f ./deploy/docker-compose/docker-compose.monitoring.yml up -d
```

Wait for the deployment to be ready. Check the status with

```
$ docker-compose -f ./deploy/docker-compose/docker-compose.monitoring.yml ps
```

### Importing The Dashboards

You only need to do this once:

```
$ docker-compose \
    -f ./deploy/docker-compose/docker-compose.monitoring.yml \
    run \
    --entrypoint /opt/grafana-import-dashboards/import.sh \
    --rm \
    importer
```

### Accessing The Services
Once the services are up & running you can access them with the following URLs:

  * Prometheus: <http://localhost:9090>
  * Grafana: <http://localhost:3000>

### Grafana Credentials
<table class="user-creds">
  <thead>
    <tr>
      <td>Username</td>
      <td>Password</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>admin</td>
      <td>foobar</td>
    </tr>
  </tbody>
</table>

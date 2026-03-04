---
mapped_pages:
  - https://www.elastic.co/guide/en/ecs-logging/ruby/current/setup.html
navigation_title: Get started
---

# Get started with ECS Logging Ruby

## Step 1: Set up application logging

### Add the dependency

Add this line to your application’s Gemfile:

```ruby
gem 'ecs-logging'
```

Execute with:

```bash
bundle install
```

Alternatively, you can install the package yourself with:

```bash
gem install ecs-logging
```

### Configure

`EcsLogging::Logger` is a subclass of Ruby’s own [`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.md) and responds to the same methods.

For example:

```ruby
require 'ecs_logging/logger'

logger = EcsLogging::Logger.new($stdout)
logger.info('my informative message')
logger.warn { 'be aware that…' }
logger.error('a_progname') { 'oh no!' }
```

Logs the following JSON to `$stdout`:

```json
{"@timestamp":"2020-11-24T13:32:21.329Z","log.level":"INFO","message":"very informative","ecs.version":"8.11.0"}
 {"@timestamp":"2020-11-24T13:32:21.330Z","log.level":"WARN","message":"be aware that…","ecs.version":"8.11.0"}
 {"@timestamp":"2020-11-24T13:32:21.331Z","log.level":"ERROR","message":"oh no!","ecs.version":"8.11.0","process.title":"a_progname"}
```

Additionally, it allows for adding additional keys to messages.

For example:

```ruby
logger.info('ok', labels: { my_label: 'value' }, 'trace.id': 'abc-xyz')
```

Logs the following:

```json
{
  "@timestamp":"2020-11-24T13:32:21.331Z",
  "log.level":"INFO",
  "message":"oh no!",
  "ecs.version":"8.11.0",
  "labels":{"my_label":"value"},
  "trace.id":"abc-xyz"
}
```

To include info about where the log was called, call the methods with `include_origin: true`, like `logger.warn('Hello!', include_origin: true)`. This logs:

```json
{
  "@timestamp":"2020-11-24T13:32:21.331Z",
  "log.level":"WARN",
  "message":"Hello!",
  "ecs.version":"8.11.0",
  "log.origin": {
    "file.line": 123,
    "file.name": "my_file.rb",
    "function": "call"
  }
}
```

### Rack configuration

```ruby
use EcsLogging::Middleware, $stdout
```

Example output:

```json
{
  "@timestamp":"2020-12-07T13:44:04.568Z",
  "log.level":"INFO",
  "message":"GET /",
  "ecs.version":"8.11.0",
  "client":{
    "address":"127.0.0.1"
  },
  "http":{
    "request":{
      "method":"GET"
    }
  },
  "url":{
    "domain":"example.org",
    "path":"/",
    "port":"80",
    "scheme":"http"
  }
}
```

## Step 2: Enable APM log correlation (optional)

If you are using the Elastic APM Ruby agent, [enable log correlation](https://www.elastic.co/guide/en/apm/agent/ruby/current/log-correlation.html).

## Step 3: Configure Filebeat

=== "Log file"
    1. Follow the [Filebeat quick start](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html)
    2. Add the following configuration to your `filebeat.yaml` file.

    For Filebeat 7.16+

    ```yaml
    filebeat.inputs:
    - type: filestream
      paths: /path/to/logs.json
      parsers:
        - ndjson:
          overwrite_keys: true
          add_error_key: true
          expand_keys: true

    processors:
      - add_host_metadata: ~
      - add_cloud_metadata: ~
      - add_docker_metadata: ~
      - add_kubernetes_metadata: ~
    ```

    For Filebeat < 7.16

    ```yaml
    filebeat.inputs:
    - type: log
      paths: /path/to/logs.json
      json.keys_under_root: true
      json.overwrite_keys: true
      json.add_error_key: true
      json.expand_keys: true

    processors:
    - add_host_metadata: ~
    - add_cloud_metadata: ~
    - add_docker_metadata: ~
    - add_kubernetes_metadata: ~
    ```

=== "Kubernetes"
    1. Make sure your application logs to stdout/stderr.
    2. Follow the [Run Filebeat on Kubernetes](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-kubernetes.html) guide.
    3. Enable hints-based autodiscover (uncomment the corresponding section in `filebeat-kubernetes.yaml`).
    4. Add these annotations to your pods that log using ECS loggers. This will make sure the logs are parsed appropriately.

    ```yaml
    annotations:
      co.elastic.logs/json.overwrite_keys: true
      co.elastic.logs/json.add_error_key: true
      co.elastic.logs/json.expand_keys: true
    ```

=== "Docker"
    1. Make sure your application logs to stdout/stderr.
    2. Follow the [Run Filebeat on Docker](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html) guide.
    3. Enable hints-based autodiscover.
    4. Add these labels to your containers that log using ECS loggers. This will make sure the logs are parsed appropriately.

    ```yaml
    labels:
      co.elastic.logs/json.overwrite_keys: true
      co.elastic.logs/json.add_error_key: true
      co.elastic.logs/json.expand_keys: true
    ```

For more information, see the [Filebeat reference](https://www.elastic.co/guide/en/beats/filebeat/current/configuring-howto-filebeat.html).


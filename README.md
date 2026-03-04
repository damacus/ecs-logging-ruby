# ecs-logging-ruby

[![Gem](https://img.shields.io/gem/v/ecs-logging.svg)](https://rubygems.org/gems/ecs-logging)

A set of libraries to transform your Ruby application logs to structured logs that comply with the [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/ecs-reference.html).

ECS logs are designed to be ingested by Elasticsearch via Filebeat or other collectors, and leveraged in Kibana.

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecs-logging'
```

And then execute:

```bash
$ bundle install
```

## Documentation

Full documentation is built with [Zensical](https://zensical.org) and available in the `docs/` directory.

The docs are also published as a container image to **GitHub Container Registry**:
`ghcr.io/damacus/ecs-logging-ruby-docs:latest`

## Usage

### Using the Logger directly

```ruby
require 'ecs_logging/logger'

logger = EcsLogging::Logger.new($stdout)
logger.info("Hello world!")
# => {"@timestamp":"2021-02-09T12:00:00.000Z","log.level":"INFO","message":"Hello world!","ecs.version":"8.11.0"}
```

### Using as Rack Middleware

```ruby
require 'ecs_logging/middleware'

use EcsLogging::Middleware, $stdout
```

## License

Apache 2.0

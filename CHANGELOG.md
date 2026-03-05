# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0 (2026-03-04)


### Features

* optimize logging hot-path and add release automation ([ada7773](https://github.com/damacus/ecs-logging-ruby/commit/ada7773db6ee99b675bb2381749161e133c9c638))
* optimize logging hot-path and modernize project structure ([7aee3e3](https://github.com/damacus/ecs-logging-ruby/commit/7aee3e3d76d9afb5e9e6f8a50903787147b7a8fa))


### Bug Fixes

* resolve Rails compatibility issues (Issue [#25](https://github.com/damacus/ecs-logging-ruby/issues/25)) ([4a7679d](https://github.com/damacus/ecs-logging-ruby/commit/4a7679d4e131291f1d50e199b805c3c41d4437f5))

## [1.0.0] - 2021-02-09

### Added
- Add tracing IDs from Elastic APM if running alongside [#14](https://github.com/elastic/ecs-logging-ruby/pull/14)

## [0.2.1] - 2021-01-13

### Fixed
- Calling severity methods without a progname [#13](https://github.com/elastic/ecs-logging-ruby/pull/13)

## [0.2.0] - 2020-12-09

### Added
- Use `include_origin` to attach stack traces to logs [#1](https://github.com/elastic/ecs-logging-ruby/pull/1)
- More fields logged when using Rack middleware [#6](https://github.com/elastic/ecs-logging-ruby/pull/6)

## [0.1.0] - 2020-11-25

- Initial release

# frozen_string_literal: true

require 'time'
require 'json'

module EcsLogging
  class Formatter
    ECS_VERSION = "8.11.0".freeze

    def call(severity, time, progname, msg, extras = nil)
      base = {
        "@timestamp": time.utc.iso8601(3),
        "log.level": severity,
        "message": msg,
        "ecs.version": ECS_VERSION
      }

      base[:"log.logger"] = progname if progname

      base.merge!(extras) if extras && !extras.empty?

      JSON.fast_generate(base) << "\n"
    end
  end
end

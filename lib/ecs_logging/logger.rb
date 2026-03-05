# frozen_string_literal: true

require "logger"
require "ecs_logging/formatter"

module EcsLogging
  class Logger < (defined?(::ActiveSupport::Logger) ? ::ActiveSupport::Logger : ::Logger)
    def initialize(*args)
      super
      self.formatter = Formatter.new
    end

    # Provide a stub for silence if not already defined (e.g. non-Rails env or old ActiveSupport)
    # This prevents crashes in Rails initialization (Fixes Issue #25)
    def silence(*)
      yield self
    end

    def add(severity, message = nil, progname = nil, include_origin: false, **extras)
      severity ||= UNKNOWN

      return true if @logdev.nil? or severity < level
      progname = @progname if progname.nil?

      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end

      if apm_agent_present_and_running?
        if txn = ElasticAPM.current_transaction
          extras[:"transaction.id"] = txn.id
          extras[:"trace.id"] = txn.trace_id
        end
        if span = ElasticAPM.current_span
          extras[:"span.id"] = span.id
        end
      end

      @logdev.write(
        format_message(
          format_severity(severity),
          Time.now,
          progname,
          message,
          extras
        )
      )

      true
    end

    %w[unknown fatal error warn info debug].each do |severity|
      define_method(severity) do |progname = nil, include_origin: false, **extras, &block|
        if include_origin && origin = origin_from_caller(caller_locations(1, 1))
          extras[:"log.origin"] = origin
        end

        name = severity.upcase.to_sym
        cnst = self.class.const_get(name)
        add(cnst, nil, progname, include_origin: include_origin, **extras, &block)
      end
    end

    private

    def origin_from_caller(locations)
      return unless location = locations&.first

      {
        'file.name': File.basename(location.path),
        'file.line': location.lineno,
        function: location.label
      }
    end

    def format_message(severity, datetime, progname, msg, extras = nil)
      formatter.call(severity, datetime, progname, msg, extras)
    end

    def apm_agent_present_and_running?
      @apm_present ||= defined?(::ElasticAPM)
      return false unless @apm_present

      ElasticAPM.running?
    end
  end
end

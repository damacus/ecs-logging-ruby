# frozen_string_literal: true

module EcsLogging
  class BodyProxy
    def initialize(body, &block)
      @body = body
      @block = block
      @closed = false
    end

    def each(&block)
      @body.each(&block)
    end

    def to_path
      @body.to_path if @body.respond_to?(:to_path)
    end

    def respond_to_missing?(name, include_all = false)
      super || @body.respond_to?(name, include_all)
    end

    def method_missing(name, *args, &block)
      @body.__send__(name, *args, &block)
    end

    def close
      return if closed?

      @closed = true

      begin
        @body.close if @body.respond_to?(:close)
      ensure
        @block.call
      end
    end

    def closed?
      @closed
    end
  end
end

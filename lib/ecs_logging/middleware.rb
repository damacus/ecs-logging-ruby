# frozen_string_literal: true

require 'ecs_logging/logger'
require 'ecs_logging/body_proxy'

module EcsLogging
  class Middleware
    def initialize(app, logdev)
      @app = app
      @logger = Logger.new(logdev)
    end

    def call(env)
      status, headers, body = @app.call(env)
      body = BodyProxy.new(body) { log(env, status, headers) }
      [status, headers, body]
    end

    private

    def log(env, status, headers)
      req_method = env['REQUEST_METHOD']
      path = env['PATH_INFO']
      
      extras = {
        client: { address: env['REMOTE_ADDR'] },
        http: { 
          request: { method: req_method } 
        },
        url: {
          domain: env['HTTP_HOST'],
          path: path,
          port: env['SERVER_PORT'],
          scheme: env['HTTPS'] == 'on' ? 'https' : 'http'
        }
      }

      if content_length = env['CONTENT_LENGTH']
        extras[:http][:request][:'body.bytes'] = content_length
      end

      if user_agent = env['HTTP_USER_AGENT']
        extras[:user_agent] = { original: user_agent }
      end

      @logger.add(
        status >= 500 ? Logger::ERROR : Logger::INFO,
        "#{req_method} #{path}",
        **extras
      )
    end
  end
end


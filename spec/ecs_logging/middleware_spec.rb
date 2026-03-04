# frozen_string_literal: true

require 'rack/test'
require 'sinatra/base'

require 'ecs_logging/middleware'

module EcsLogging
  RSpec.describe Middleware do
    include Rack::Test::Methods

    def app
      MyApp
    end

    TestIO = StringIO.new

    before :all do
      class MyApp < Sinatra::Base
        use EcsLogging::Middleware, TestIO

        disable :show_exceptions
        set :host_authorization, permitted_hosts: [] if respond_to?(:host_authorization)

        get '/' do
          'ok'
        end
      end
    end

    let(:log) { TestIO.rewind; TestIO.read }

    it 'logs GET requests' do
      resp = get '/'

      expect(resp.body).to eq 'ok'
      expect(log.lines.count).to be 1

      json = JSON.parse(log.lines.last)

      expect(json).to match(
        '@timestamp' => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
        'log.level' => "INFO",
        'message' => "GET /",
        'ecs.version' => '8.11.0',
        'client' => { 'address' => '127.0.0.1' },
        'http' => {
          'request' => {
            'method' => 'GET'
          }
        },
        'url' => {
          'domain' => 'example.org',
          'path' => '/',
          'port' => '80',
          'scheme' => 'http'
        }
      )
    end

    it 'ensures key order' do
      resp = get '/'
      json = JSON.parse(log.lines.last)

      expect(json.keys.first(4)).to eq %w[@timestamp log.level message ecs.version]
    end

    it 'logs metadata' do
      get '/', {}, { 'HTTP_USER_AGENT' => 'Mozilla/5.0', 'CONTENT_LENGTH' => '123' }
      json = JSON.parse(log.lines.last)

      expect(json['user_agent']['original']).to eq 'Mozilla/5.0'
      expect(json['http']['request']['body.bytes']).to eq '123'
    end

    it 'logs scheme' do
      get '/', {}, { 'HTTPS' => 'on' }
      json = JSON.parse(log.lines.last)

      expect(json['url']['scheme']).to eq 'https'
    end

    it 'logs 500 as ERROR' do
      class MyApp < Sinatra::Base
        get '/error' do
          [500, {}, 'error']
        end
      end

      get '/error'
      json = JSON.parse(log.lines.last)

      expect(json['log.level']).to eq 'ERROR'
    end
  end
end

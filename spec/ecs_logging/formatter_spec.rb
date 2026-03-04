# frozen_string_literal: true

require "spec_helper"
require "ecs_logging/formatter"

module EcsLogging
  RSpec.describe Formatter do
    let(:time) { Time.utc(2026, 3, 4, 12, 0, 0) }
    
    it "formats a basic message" do
      result = subject.call("INFO", time, nil, "hello")
      json = JSON.parse(result)
      
      expect(json).to eq({
        "@timestamp" => "2026-03-04T12:00:00.000Z",
        "log.level" => "INFO",
        "message" => "hello",
        "ecs.version" => "8.11.0"
      })
    end

    it "includes progname as log.logger" do
      result = subject.call("INFO", time, "my-app", "hello")
      json = JSON.parse(result)
      expect(json["log.logger"]).to eq "my-app"
    end

    it "merges extras" do
      result = subject.call("INFO", time, nil, "hello", custom: "value", nested: { a: 1 })
      json = JSON.parse(result)
      expect(json["custom"]).to eq "value"
      expect(json["nested"]).to eq({ "a" => 1 })
    end
    
    it "adds a newline at the end" do
      result = subject.call("INFO", time, nil, "hello")
      expect(result).to end_with("\n")
    end
  end
end

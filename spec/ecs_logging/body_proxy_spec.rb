# frozen_string_literal: true

require "spec_helper"
require "ecs_logging/body_proxy"

module EcsLogging
  RSpec.describe BodyProxy do
    let(:body) { ["a", "b", "c"] }
    let(:callback) { double("callback", call: nil) }
    subject { described_class.new(body) { callback.call } }

    it "delegates each" do
      yielded = []
      subject.each { |part| yielded << part }
      expect(yielded).to eq body
    end

    it "delegates to_path if present" do
      allow(body).to receive(:to_path).and_return("/foo/bar")
      expect(subject.to_path).to eq "/foo/bar"
    end

    it "handles missing to_path gracefully" do
      expect(subject.to_path).to be_nil
    end

    it "delegates other methods via method_missing" do
      allow(body).to receive(:some_method).with(1).and_return(2)
      expect(subject.some_method(1)).to eq 2
    end

    it "responds to delegated methods" do
      allow(body).to receive(:some_method)
      expect(subject.respond_to?(:some_method)).to be true
      expect(subject.respond_to?(:each)).to be true
    end

    it "calls the block exactly once on close" do
      expect(callback).to receive(:call).once
      subject.close
      subject.close
    end

    it "delegates close to the body" do
      expect(body).to receive(:close)
      subject.close
    end
  end
end

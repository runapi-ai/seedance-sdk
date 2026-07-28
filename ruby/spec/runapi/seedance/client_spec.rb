# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunApi::Seedance::Client do
  before do
    allow(ConnectionPool).to receive(:new).and_return(instance_double(ConnectionPool))
  end

  after { RunApi.api_key = nil }

  it "accepts api_key as parameter" do
    client = described_class.new(api_key: "param-key")
    expect(client).to be_a(described_class)
  end

  it "falls back to global RunApi.api_key" do
    RunApi.api_key = "global-key"
    client = described_class.new
    expect(client).to be_a(described_class)
  end

  context "with custom http_client" do
    it "uses the provided http_client" do
      custom_http = double("custom_http")
      client = described_class.new(api_key: "test-key", http_client: custom_http)
      expect(client.text_to_video.instance_variable_get(:@http)).to eq(custom_http)
    end

    it "falls back to Core::HttpClient when http_client is nil" do
      allow(ConnectionPool).to receive(:new).and_return(instance_double(ConnectionPool))
      client = described_class.new(api_key: "test-key")
      expect(client.text_to_video.instance_variable_get(:@http)).to be_a(RunApi::Core::HttpClient)
    end
  end

  it "exposes text_to_video accessor" do
    client = described_class.new(api_key: "test-key")
    expect(client.text_to_video).to be_a(RunApi::Seedance::Resources::TextToVideo)
  end
end

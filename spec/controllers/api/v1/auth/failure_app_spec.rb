require "rails_helper"

RSpec.describe Api::V1::Auth::FailureApp do
  subject(:failure_app) do
    app = described_class.new
    app.instance_variable_set(:@_response, ActionDispatch::Response.new)
    app
  end

  describe "#respond" do
    it "returns unauthorized JSON error response" do
      allow(failure_app).to receive(:i18n_message).and_return("Invalid token")

      failure_app.respond

      body = failure_app.response_body.is_a?(Array) ? failure_app.response_body.join : failure_app.response_body

      expect(failure_app.status).to eq(401)
      expect(failure_app.content_type).to start_with("application/json")
      expect(JSON.parse(body)).to eq("error" => "Invalid token")
    end

    it "falls back to default unauthorized message when i18n message is blank" do
      allow(failure_app).to receive(:i18n_message).and_return(nil)

      failure_app.respond

      body = failure_app.response_body.is_a?(Array) ? failure_app.response_body.join : failure_app.response_body

      expect(failure_app.status).to eq(401)
      expect(JSON.parse(body)).to eq("error" => "Unauthorized")
    end
  end
end

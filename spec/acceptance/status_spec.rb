require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Api::V1::Status" do
  api_header
  get "/api/v1/status/client_info" do
    example "Client Info" do
      do_request

      expect(status).to eq(200)
    end
  end
end

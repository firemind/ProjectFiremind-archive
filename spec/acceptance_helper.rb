require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = :json
  config.curl_host = 'https://www.firemind.ch'
  config.api_name = "Firemind API"
end

def api_header
  header "Accept", "application/json"
  header "Content-Type", "application/json"
  header "Host", "www.firemind.ch"
end

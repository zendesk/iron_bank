# frozen_string_literal: true

A_ZUORA_ID = /[a-z0-9]{32}/.freeze
AN_ENTITY  = /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/.freeze

FAKE_ZUORA_ID   = '2c92abc0123def234ghi345jkl456mno'
FAKE_BEARER     = 'Bearer 001abc002def003ghi004jkl005mno00'
FAKE_ENTITY     = '11111111-2222-3333-4444-555555555555'
FAKE_REQUEST_ID = '00000000-9999-8888-7777-666666666666'

VCR.configure do |vcr|
  vcr.cassette_library_dir = 'spec/vcr'
  vcr.hook_into :webmock
  vcr.configure_rspec_metadata!

  # Filter the client ID passed during the POST to /oauth/token
  vcr.filter_sensitive_data('<CLIENT_ID>') do
    CGI.escape ENV['ZUORA_CLIENT_ID']
  end

  # Filter the client secret passed during the POST to /oauth/token
  vcr.filter_sensitive_data('<CLIENT_SECRET>') do
    CGI.escape ENV['ZUORA_CLIENT_SECRET']
  end

  # Filter the Zuora tenant ID
  vcr.filter_sensitive_data('<TENANT_ID>') { ENV['ZUORA_TENANT_ID'] }

  # Dynamic filters
  vcr.before_record do |interaction|
    # REQUEST
    request_headers = interaction.request.headers

    # Replace the bearer token
    if request_headers['Authorization']
      request_headers['Authorization'] = ['Bearer <TOKEN>']
    end

    # RESPONSE
    response_headers = interaction.response.headers

    # Check the body for any Zuora ID
    response_body = interaction.response.body
    response_body.gsub!(A_ZUORA_ID, '<A_ZUORA_ID>')
    response_body.gsub!(AN_ENTITY, '<AN_ENTITY>')
    interaction.response.body = response_body

    # Replace the response 'Zuora-Request-Id' if present
    if response_headers['Zuora-Request-Id']
      response_headers['Zuora-Request-Id'] = ['<ZUORA_REQUEST_ID>']
    end

    # Replace the response 'X-Request-Id' if present
    if response_headers['X-Request-Id']
      response_headers['X-Request-Id'] = ['<ZUORA_REQUEST_ID>']
    end

    # Delete the 'Content-Security-Policy-Report-Only' if present
    response_headers.delete('Content-Security-Policy-Report-Only')
  end

  vcr.before_playback do |interaction|
    # REQUEST
    request_headers = interaction.request.headers

    # Replace the bearer token
    if request_headers['Authorization']
      request_headers['Authorization'] = [FAKE_BEARER]
    end

    # RESPONSE
    response_headers = interaction.response.headers

    body = interaction.response.body
    body.gsub!('<A_ZUORA_ID>', FAKE_ZUORA_ID)
    body.gsub!('<AN_ENTITY>', FAKE_ENTITY)
    interaction.response.body = body

    # Replace the response 'Zuora-Request-Id' if present
    if response_headers['Zuora-Request-Id']
      response_headers['Zuora-Request-Id'] = [FAKE_REQUEST_ID]
    end

    # Replace the response 'X-Request-Id' if present
    if response_headers['X-Request-Id']
      response_headers['X-Request-Id'] = [FAKE_REQUEST_ID]
    end
  end
end

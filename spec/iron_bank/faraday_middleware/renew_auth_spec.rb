# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::FaradayMiddleware::RenewAuth do
  let(:session)         { instance_double(IronBank::Authentications::Token) }
  let(:auth)            { instance_double(IronBank::Authentication) }
  let(:new_auth_header) { { 'Authorization' => 'Bearer foo' } }

  let(:make_request) { connection.get('/resource') }

  let(:connection_stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/resource', new_auth_header) do
        [200, { 'Content-Type' => 'application/json' }, '{"status": "ok"}']
      end

      stub.get('/resource') do
        [401, { 'Content-Type' => 'application/json' }, '{"status": "bad"}']
      end
    end
  end

  before do
    allow(auth).to receive(:renew_session).and_return(session).once
    allow(auth).to receive(:header).and_return(new_auth_header).once
  end

  describe 'first request' do
    before { make_request }

    it { expect(auth).to have_received(:renew_session) }
    it { expect(auth).to have_received(:header) }
  end

  describe 'second request' do
    it 'includes the Authorization header with value' do
      request_headers = make_request.env.request_headers
      expect(request_headers['Authorization']).to eq('Bearer foo')
    end

    it 'returns ok' do
      expect(make_request.body).to eq('{"status": "ok"}')
    end
  end

  private

  # :reek:FeatureEnvy
  def connection
    Faraday.new do |conn|
      # To simulate a second request with new auth headers
      conn.request :retry, max: 2, exceptions: [IronBank::UnauthorizedError]

      conn.response :raise_error
      conn.response :renew_auth, auth

      conn.adapter :test, connection_stubs
    end
  end
end

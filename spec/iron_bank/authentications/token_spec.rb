# frozen_string_literal: true

require 'spec_helper'
require 'timecop'

RSpec.describe IronBank::Authentications::Token do
  let(:initial_token) do
    {
      'access_token' => 123,
      'expires_in'   => 3599
    }
  end

  let(:refreshed_token) do
    {
      'access_token' => 456,
      'expires_in'   => 3599
    }
  end

  let(:invalid_token) do
    {
      'access_token' => nil,
      'expires_in'   => 3599
    }
  end

  let(:initial_authorization_header) do
    { 'Authorization' => "Bearer #{initial_token['access_token']}" }
  end

  let(:refreshed_authorization_header) do
    { 'Authorization' => "Bearer #{refreshed_token['access_token']}" }
  end

  let(:invalid_token_response) do
    instance_double(Faraday::Response, body: invalid_token)
  end

  let(:client_id)     { 'client-id-from-zuora' }
  let(:client_secret) { 'client-secret-from-zuora' }
  let(:base_url)      { 'https://domain.com' }

  let(:credentials) do
    {
      client_id:     client_id,
      client_secret: client_secret,
      base_url:      base_url
    }
  end

  let(:first_response) do
    instance_double(Faraday::Response, body: initial_token)
  end

  let(:second_response) do
    instance_double(Faraday::Response, body: refreshed_token)
  end

  let(:connection) { instance_double(Faraday::Connection) }

  subject { described_class.call(credentials) }

  before do
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:post).
      and_return(first_response, second_response)
  end

  describe '#header' do
    subject(:a_token) { described_class.new(credentials) }

    context 'token not expired' do
      before do
        Timecop.freeze(Time.local(2017))
      end

      after { Timecop.return }

      it 'returns the authorization with bearer header' do
        expect(a_token.header).to eq(initial_authorization_header)
      end
    end

    context 'token expired' do
      subject(:expired) do
        Timecop.travel(Time.local(2019))
        a_token.header
      end

      before do
        Timecop.freeze(Time.local(2017))
        a_token.header
      end

      after { Timecop.return }

      it 'renews the authorization with new bearer header' do
        expect(expired).to eq(refreshed_authorization_header)
      end
    end

    context 'invalid token returning from endpoint' do
      before do
        allow(connection).to receive(:post).and_return(invalid_token_response)
      end

      specify do
        expect { a_token.header }.to raise_error(
          described_class::InvalidAccessToken
        )
      end
    end
  end

  describe '#expired?' do
    subject(:a_token) { described_class.new(credentials) }

    context 'token not expired' do
      before do
        Timecop.freeze(Time.local(2017))
      end

      after { Timecop.return }

      it 'returns false' do
        expect(a_token.expired?).to be_falsey
      end
    end

    context 'token expired' do
      subject(:expired) do
        Timecop.travel(Time.local(2019))
        a_token
      end

      before do
        Timecop.freeze(Time.local(2017))
        a_token.header
      end

      after { Timecop.return }

      it 'returns true' do
        expect(expired.expired?).to be_truthy
      end
    end
  end
end

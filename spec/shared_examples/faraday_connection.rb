# frozen_string_literal: true

RSpec.shared_examples "Faraday::Connection configuration block" do
  before do
    allow(Faraday).to receive(:new).and_yield(connection).and_return(connection)

    # Faraday::Connection configuration
    allow(connection).to receive(:request)
    allow(connection).to receive(:response)
    allow(connection).to receive(:adapter)
  end

  subject(:faraday_connection) do
    described_class.new(credentials).send(:connection)
  end

  it "uses URL encoded format for the request" do
    faraday_connection
    expect(connection).to have_received(:request).with(:url_encoded)
  end

  it "set the response to be parsed using JSON" do
    faraday_connection
    expect(connection).to have_received(:request).with(:url_encoded)
  end

  it "uses the default Faraday adapter" do
    faraday_connection

    expect(connection).
      to have_received(:adapter).
      with(Faraday.default_adapter)
  end

  describe "IronBank configurable middlewares" do
    before do
      allow(connection).to receive(:use)
    end

    context "no middleware configured" do
      it "does not configure the Faraday::Connection to use any" do
        faraday_connection

        expect(connection).to_not have_received(:use)
      end
    end

    context "with a middleware configured" do
      before { IronBank.configuration.middlewares = %i[Foo Bar] }
      after  { IronBank.configuration.middlewares = [] }

      it "configures the Faraday::Connection to use the middlewares" do
        faraday_connection

        expect(connection).to have_received(:use).with(:Foo, nil)
        expect(connection).to have_received(:use).with(:Bar, nil)
      end
    end
  end
end

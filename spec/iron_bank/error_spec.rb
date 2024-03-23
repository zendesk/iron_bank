# frozen_string_literal: true

RSpec.describe IronBank::Error do
  describe "::from_response" do
    let(:response) { instance_double(Faraday::Response) }

    before do
      allow(response).to receive(:status).
        and_return(status)
    end

    subject(:error) { described_class.from_response(response) }

    shared_examples "returning the correct error" do
      it { is_expected.to be_a(expected_error) }
    end

    context "for a response with a 200 status code" do
      let(:status) { 200 }

      it "delegates to ::from_body" do
        expect(described_class).to receive(:from_body)

        subject
      end
    end

    context "for a response with a 400 status code" do
      let(:status)         { 400 }
      let(:expected_error) { IronBank::BadRequestError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with a 401 status code" do
      let(:status)         { 401 }
      let(:expected_error) { IronBank::UnauthorizedError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with a 404 status code" do
      let(:status)         { 404 }
      let(:expected_error) { IronBank::NotFoundError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with a 422 status code" do
      let(:status)         { 422 }
      let(:expected_error) { IronBank::UnprocessableEntityError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with a 429 status code" do
      let(:status)         { 429 }
      let(:expected_error) { IronBank::TooManyRequestsError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with a 500 status code" do
      let(:status)         { 500 }
      let(:expected_error) { IronBank::InternalServerError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with any other 400 status code" do
      let(:status)         { 499 }
      let(:expected_error) { IronBank::ClientError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with any other 500 status code" do
      let(:status)         { 599 }
      let(:expected_error) { IronBank::ServerError }

      it_behaves_like "returning the correct error"
    end

    context "for a response with any other status code" do
      let(:status)         { 600 }
      let(:expected_error) { IronBank::Error }

      it_behaves_like "returning the correct error"
    end
  end

  describe "::from_body" do
    let(:response) { instance_double(Faraday::Response) }
    let(:body)     { "CODE: #{code}" }

    before do
      allow(response).to receive(:body).
        and_return(body)
    end

    subject(:error) { described_class.from_body(response) }

    shared_examples "returning the correct error class" do
      it { is_expected.to eq(expected_error) }
    end

    shared_examples "returning no error class" do
      it { is_expected.to eq(nil) }
    end

    context 'when response is a Hash' do
      context 'when a custom field contains "INVALID_VALUE"' do
        let(:body) do
          {
            'Id' => '2c92c0f97aa8ed71017aaad5c77e6a1f',
            'Notes' => 'RENEWAL_ERROR: ${:code=>"INVALID_VALUE", :message=>"error_message."}$\n\n',
            'RenewalTerm' => 12
          }
        end

        it_behaves_like "returning no error class"
      end

      context 'when faultcode exists' do
        let(:body) do
          {
            "detail" => {
              "MalformedQueryFault" => {
                "FaultMessage" => "foo",
                "FaultCode" => "UNKNOWN_ERROR"
              }
            },
            "faultcode" => "fns:UNKNOWN_ERROR",
            "faultstring" => "foo"
          }
        end

        let(:expected_error) { IronBank::InternalServerError }

        it_behaves_like "returning the correct error class"
      end

      context 'when "where" response contains custom field with "INVALID_VALUE"' do
        let(:body) do
          {
            "records" => [
              {
                "Id" => "2c92c",
                "SubscriptionStartDate" => "2021-07-09",
                "Notes" =>
                  "RENEWAL_ERROR: ${:code=>\"INVALID_VALUE\", :message=>\"error_message.\"}$",
                "Name" => "A-S001",
                "ServiceActivationDate" => "2021-07-09"
              }
            ],
            "done" => true,
            "size" => 1
          }
        end

        it_behaves_like "returning no error class"
      end

      context 'when bulk request response with faultcode' do
        let(:body) do
          {
            "results" => [
              {
                "Success" => false,
                "Errors" => [
                  {
                    "Code" => "INVALID_VALUE",
                    "Message" => "Invalid value"
                  }
                ]
              }
            ]
          }
        end

        let(:expected_error) { IronBank::BadRequestError }

        it_behaves_like "returning the correct error class"
      end
    end

    context "for a body with a `API_DISABLED` code" do
      let(:code)           { "API_DISABLED" }
      let(:expected_error) { IronBank::ServerError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `CANNOT_DELETE` code" do
      let(:code)           { "CANNOT_DELETE" }
      let(:expected_error) { IronBank::UnprocessableEntityError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `DUPLICATE_VALUE` code" do
      let(:code)           { "DUPLICATE_VALUE" }
      let(:expected_error) { IronBank::ConflictError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `INVALID_FIELD` code" do
      let(:code)           { "INVALID_FIELD" }
      let(:expected_error) { IronBank::BadRequestError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `INVALID_ID` code" do
      let(:code)           { "INVALID_ID" }
      let(:expected_error) { IronBank::BadRequestError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `INVALID_TYPE` code" do
      let(:code)           { "INVALID_TYPE" }
      let(:expected_error) { IronBank::BadRequestError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `INVALID_VALUE` code" do
      let(:code)           { "INVALID_VALUE" }
      let(:expected_error) { IronBank::BadRequestError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `LOCK_COMPETITION` code" do
      let(:code)           { "LOCK_COMPETITION" }
      let(:expected_error) { IronBank::LockCompetitionError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `MALFORMED_QUERY` code" do
      let(:code)           { "MALFORMED_QUERY" }
      let(:expected_error) { IronBank::ClientError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `MISSING_REQUIRED_VALUE` code" do
      let(:code)           { "MISSING_REQUIRED_VALUE" }
      let(:expected_error) { IronBank::ClientError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `REQUEST_EXCEEDED_LIMIT` code" do
      let(:code)           { "REQUEST_EXCEEDED_LIMIT" }
      let(:expected_error) { IronBank::TooManyRequestsError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `REQUEST_EXCEEDED_RATE` code" do
      let(:code)           { "REQUEST_EXCEEDED_RATE" }
      let(:expected_error) { IronBank::TooManyRequestsError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `TEMPORARY_ERROR` code" do
      let(:code)           { "TEMPORARY_ERROR" }
      let(:expected_error) { IronBank::TemporaryError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `TRANSACTION_FAILED` code" do
      let(:code)           { "TRANSACTION_FAILED" }
      let(:expected_error) { IronBank::InternalServerError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `TRANSACTION_TERMINATED` code" do
      let(:code)           { "TRANSACTION_TERMINATED" }
      let(:expected_error) { IronBank::InternalServerError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `TRANSACTION_TIMEOUT` code" do
      let(:code)           { "TRANSACTION_TIMEOUT" }
      let(:expected_error) { IronBank::BadGatewayError }

      it_behaves_like "returning the correct error class"
    end

    context "for a body with a `UNKNOWN_ERROR` code" do
      let(:code)           { "UNKNOWN_ERROR" }
      let(:expected_error) { IronBank::InternalServerError }

      it_behaves_like "returning the correct error class"
    end
  end
end

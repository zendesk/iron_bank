# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Amend do
  it_behaves_like 'a Zuora action' do
    let(:args)     { { requests: [request1, request2] } }
    let(:request1) { { amendments: [], preview_options: {} } }
    let(:request2) { { amendments: [], preview_options: {} } }
    let(:endpoint) { 'v1/action/amend' }

    let(:params) do
      {
        requests: [
          { 'Amendments' => [], 'PreviewOptions' => {} },
          { 'Amendments' => [], 'PreviewOptions' => {} }
        ]
      }
    end

    let(:body) { { 'results' => anything } }
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Update do
  it_behaves_like 'a Zuora action' do
    let(:args) do
      {
        objects: [
          { id: 'some-zuora-id-123', name: 'new-name-1' },
          { id: 'some-zuora-id-234', name: 'new-name-2' }
        ],
        type: 'Account'
      }
    end

    let(:endpoint) { 'v1/action/update' }

    let(:params) do
      {
        objects: [
          { 'Id' => 'some-zuora-id-123', 'Name' => 'new-name-1' },
          { 'Id' => 'some-zuora-id-234', 'Name' => 'new-name-2' }
        ],
        type: 'Account'
      }
    end
  end
end

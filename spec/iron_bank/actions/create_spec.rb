# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Create do
  it_behaves_like 'a Zuora action' do
    let(:args)     { { type: :account, objects: [object1, object2] } }
    let(:object1)  { { name: 'test-account-1' } }
    let(:object2)  { { name: 'test-account-2' } }
    let(:endpoint) { 'v1/action/create' }

    let(:params) do
      {
        type:    'Account',
        objects: [
          { 'Name' => 'test-account-1' },
          { 'Name' => 'test-account-2' }
        ]
      }
    end

    let(:body) do
      [
        { 'Success' => true, 'Id' => 'id-1' },
        { 'Success' => true, 'Id' => 'id-2' }
      ]
    end
  end
end

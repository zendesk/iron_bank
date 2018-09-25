# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Create do
  it_behaves_like 'a Zuora action' do
    let(:args) do
      {
        type: 'Account',
        objects: [
          { name: 'test-account-1' },
          { name: 'test-account-2' }
        ]
      }
    end

    let(:endpoint) { 'v1/action/create' }

    let(:params) do
      {
        type: 'Account',
        objects: [
          { 'Name' => 'test-account-1' },
          { 'Name' => 'test-account-2' }
        ]
      }
    end
  end
end

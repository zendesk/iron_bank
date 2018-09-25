# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Delete do
  it_behaves_like 'a Zuora action' do
    let(:args) do
      {
        ids:  ['zuora-id-123', 'zuora-id-234'],
        type: 'Account'
      }
    end

    let(:endpoint) { 'v1/action/delete' }

    let(:params) { args }
  end
end

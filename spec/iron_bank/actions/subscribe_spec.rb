# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Subscribe do
  it_behaves_like 'a Zuora action' do
    let(:args) do
      {
        subscribes: [
          { account: {}, subscribe_options: {} },
          { account: {}, subscribe_options: {} }
        ]
      }
    end

    let(:endpoint) { 'v1/action/subscribe' }

    let(:params) do
      {
        subscribes: [
          { 'Account' => {}, 'SubscribeOptions' => {} },
          { 'Account' => {}, 'SubscribeOptions' => {} }
        ]
      }
    end
  end
end

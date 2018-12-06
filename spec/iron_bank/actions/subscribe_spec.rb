# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Subscribe do
  it_behaves_like 'a Zuora action' do
    let(:args)       { { subscribes: [subscribe1, subscribe2] } }
    let(:subscribe1) { { account: {}, subscribe_options: {} } }
    let(:subscribe2) { { account: {}, subscribe_options: {} } }
    let(:endpoint)   { 'v1/action/subscribe' }

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

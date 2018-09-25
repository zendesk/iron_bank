# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Subscribe do
  it_behaves_like 'a Zuora action' do
    let(:args)              { { dummy: true } }
    let(:response_body)     { { success: true } }
    let(:endpoint)          { 'v1/action/subscribe' }
    let(:subscribe_request) { IronBank::Object.new(args).deep_camelize }
    let(:params)            { { subscribes: [subscribe_request] } }
  end
end

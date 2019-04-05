# frozen_string_literal: true

require "spec_helper"
require "logger"

RSpec.describe IronBank::Logger do
  describe "initialize without params" do
    let(:default_logger) { subject.instance_variable_get(:@logger) }
    let(:default_level) { default_logger.level }
    let(:default_progname) { default_logger.progname }

    it { expect(default_level).to eq described_class::LEVEL }
    it { expect(default_progname).to eq described_class::PROGNAME }
  end

  describe "delegates object methods to logger" do
    it { expect delegate_method(:debug).to(:logger) }

    it { expect delegate_method(:info).to(:logger) }

    it { expect delegate_method(:warn).to(:logger) }

    it { expect delegate_method(:error).to(:logger) }

    it { expect delegate_method(:fatal).to(:logger) }
  end
end

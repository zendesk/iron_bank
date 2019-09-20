# frozen_string_literal: true

RSpec.describe IronBank::User do
  before { IronBank.configuration.zuora_users_file = users_file }

  after  do
    IronBank.configuration.zuora_users_file = nil

    if described_class.instance_variable_defined?(:@store)
      described_class.remove_instance_variable(:@store)
    end
  end

  let(:users_file) { "spec/fixtures/zuora_users.csv" }

  describe ".store" do
    subject(:store) { described_class.store }

    context "when no zuora users file is configured" do
      let(:users_file) { nil }
      it { is_expected.to eq({}) }
    end

    context "when the configured zuora users file does not exist" do
      let(:users_file) { "foo.csv" }

      before { allow(IronBank.logger).to receive(:warn) }

      it "warns that the file does not exist" do
        store

        expect(IronBank.logger).
          to have_received(:warn).
          with("File does not exist: foo.csv")
      end

      it { is_expected.to eq({}) }
    end

    context "when the configured zuora users file does exist" do
      let(:users_file) { "spec/fixtures/zuora_users.csv" }

      it "creates a Hash of Zuora User ID => Zuora User instance" do
        expect(store).
          to match("zuora-user-id-23456" => an_instance_of(IronBank::User))
      end
    end
  end

  describe ".all" do
    let(:users_file) { nil }
    subject(:all)    { described_class.all }
    it               { is_expected.to eq([]) }
  end

  describe ".find" do
    subject(:find)   { described_class.find(user_id) }

    context "when a user is not found" do
      let(:user_id) { "user-id-666" }

      it "raises a NotFoundError" do
        expect { find }.
          to raise_error(IronBank::NotFoundError, "user id: #{user_id}")
      end
    end

    context "when a user is found" do
      let(:user_id) { "zuora-user-id-23456" }

      it { is_expected.to be_a(IronBank::User) }
    end
  end

  describe "an instance" do
    let(:user_id)  { "zuora-user-id-23456" }
    let(:instance) { IronBank::User.find(user_id) }

    describe "#id" do
      subject(:id) { instance.id }

      it "is aliased from #user_id" do
        expect(id).to eq(instance.user_id)
      end
    end

    describe "#inspect" do
      subject(:inspect) { instance.inspect }

      it "displays the user name" do
        expect(inspect).to match(/user_name="jane.doe@mail.com"/)
      end
    end

    describe "#last_login" do
      subject(:last_login) { instance.last_login }

      it { is_expected.to be_a(Date) }
    end

    describe "#created_on" do
      subject(:created_on) { instance.created_on }

      it { is_expected.to be_a(Date) }
    end

    describe "instance methods" do
      let(:methods) do
        described_class::FIELDS.map do |field|
          IronBank::Utils.underscore(field.tr(" ", ""))
        end
      end

      it "defines a Ruby-friendly method for each fields" do
        respond_to = methods.map { |method| instance.respond_to?(method) }

        expect(respond_to).to all(be true)
      end
    end
  end
end

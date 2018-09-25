# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/associations'
require 'shared_examples/metadata'
require 'shared_examples/queryable'

RSpec.describe IronBank::Resource do
  it_behaves_like 'a resource with metadata'
  it_behaves_like 'a resource with associations'
  it_behaves_like 'a queryable resource'

  let(:client)   { instance_double(IronBank::Client) }
  let(:id)       { 'an-id-from-zuora' }
  let(:remote)   { { 'Id' => id } }
  let(:resource) { described_class.new(remote) }

  describe '#inspect' do
    subject { resource.inspect }

    context 'without a name field' do
      it { is_expected.to match(/IronBank::Resource:0x\w+ id="#{id}/) }
    end

    context 'with a name field' do
      before do
        resource.define_singleton_method(:name) { 'resource-name' }
      end

      it { is_expected.to match(/name=\"resource-name\"/) }
    end
  end

  describe '#==' do
    subject { resource == other }

    context 'another resource instance with the same remote hash' do
      let(:other) { described_class.new(remote) }
      it { is_expected.to be(true) }
    end

    context 'another resource instance with a different remote hash' do
      let(:other) { described_class.new('Id' => 'other-id') }
      it { is_expected.to be(false) }
    end

    context 'a different object' do
      let(:other) { 'this is a string' }
      it { is_expected.to be(false) }
    end
  end

  describe '#reload' do
    let(:reloaded_remote) { { 'Id' => id, 'Name' => 'now I have a name' } }

    let(:reloaded) do
      instance_double(IronBank::Resource, remote: reloaded_remote)
    end

    subject(:reload) { resource.reload }

    before do
      allow(described_class).to receive(:find).with(id).and_return(reloaded)
    end

    it { is_expected.to eq(reloaded_remote) }

    it 'removes instance vars and updates the remote hash for the resource' do
      expect(resource.instance_variables).to eq [:@remote]

      expect { resource.reload }.
        to change(resource, :remote).
        from(remote).
        to(reloaded_remote)
    end
  end

  describe '#to_csv_row' do
    let(:remote) do
      {
        'Id'          => id,
        'CustomField' => 'custom-field-value'
      }
    end

    before do
      allow(described_class).to receive(:fields).and_return(%w[Id CustomField])
    end

    subject { resource.to_csv_row }

    it { is_expected.to eq([id, 'custom-field-value']) }
  end
end

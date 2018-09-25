# frozen_string_literal: true

RSpec.shared_examples 'a resource with associations' do
  let(:id)         { 'the-resource-id' }
  let(:remote)     { { 'Id' => id } }
  let(:instance)   { described_class.new(remote) }
  let(:associated) { double('another resource class') }

  describe '::with_one' do
    before do
      described_class.with_one :associated_object, aka: :an_object
    end

    it 'defines an instance method and an alias to find the association' do
      expect(described_class.instance_methods).
        to include(:associated_object, :an_object)
    end

    context 'calling the defined method' do
      let(:foreign_key_value) { 'associated-id' }

      subject(:with_one) { instance.associated_object }

      before do
        allow(IronBank::Resources).to receive(:const_get).and_return(associated)

        # NOTE: this method would be defined by the schema for real resources
        value = foreign_key_value # closure to return the foreign_key_value
        instance.define_singleton_method(:associated_object_id) do
          value
        end
      end

      it 'calls ::find on the associated class resource' do
        expect(associated).to receive(:find).with(foreign_key_value)
        with_one
      end

      context 'when foreign_key_value is nil' do
        let(:foreign_key_value) { nil }

        it 'calls ::find on the associated class resource' do
          expect(associated).not_to receive(:find)
          with_one
        end

        # it { is_expected.to be_nil }
      end
    end
  end

  describe '::with_many' do
    before do
      described_class.with_many :associated_objects, aka: :objects
    end

    it 'defines an instance method an alias to query the association' do
      expect(described_class.instance_methods).
        to include(:associated_objects, :objects)
    end

    context 'calling the defined method' do
      let(:foreign) { IronBank::Utils.underscore(described_class.object_name) }
      let(:conditions) { { "#{foreign}_id": id } }

      subject(:with_many) { instance.associated_objects }

      before do
        allow(IronBank::Resources).to receive(:const_get).and_return(associated)
      end

      it 'calls ::where on the associated class resource' do
        expect(associated).to receive(:where).with(conditions)
        with_many
      end
    end
  end
end

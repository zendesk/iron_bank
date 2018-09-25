# frozen_string_literal: true

RSpec.describe IronBank::CSV do
  describe 'CSV converters' do
    context ':decimal_integer' do
      let(:decimal_integer) { CSV::Converters[:decimal_integer] }

      context 'when the string is a decimal integer' do
        let(:integers) { %w[1 10 100 1000] }

        it 'returns the original string converter to an integer' do
          integers.each do |string|
            expect(decimal_integer.call(string)).to eq(string.to_i)
          end
        end
      end

      context 'when the string is not a decimal integer' do
        let(:non_integers) { %w[1.0 1. 0.1 0b10 doo] }

        it 'returns the original string' do
          non_integers.each do |string|
            expect(decimal_integer.call(string)).to eq(string)
          end
        end
      end
    end

    context ':decimal_float' do
      let(:decimal_float) { CSV::Converters[:decimal_float] }

      context 'when the string is a decimal float' do
        let(:floats) { %w[1.0 1. .1 0.1 0.1000] }

        it 'returns the original string converter to a float' do
          floats.each do |string|
            expect(decimal_float.call(string)).to eq(string.to_f)
          end
        end
      end

      context 'when the string is not a decimal float' do
        let(:non_floats) { %w[1 10 100 0b10 doo] }

        it 'returns the original string' do
          non_floats.each do |string|
            expect(decimal_float.call(string)).to eq(string)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe IronBank::Associations do
  # Sample Calculation class
  class Calc
    include IronBank::Associations
    extend IronBank::Associations::ClassMethods

    attr_reader :first_num, :second_num

    def initialize(first_num, second_num)
      @first_num = first_num
      @second_num = second_num
    end

    def sum
      with_memoization("sum_for_#{first_num}_#{second_num}") do
        calculate_sum
      end
    end

    private

    def calculate_sum
      first_num + second_num
    end
  end

  describe ".with_memoization" do
    let(:subject) { Calc.new(1, 2) }

    it "returns from the memo on second and more calls" do
      is_expected.to receive(:calculate_sum).once
      3.times do
        subject.sum == 3
      end
    end
  end
end

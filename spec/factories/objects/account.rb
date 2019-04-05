# frozen_string_literal: true

FactoryBot.define do
  factory :account, class: IronBank::Object do
    auto_pay       { true }
    batch          { "Batch20" }
    currency       { "USD" }
    bill_cycle_day { 27 }
    name           { "IronBank Tester1" }
    payment_term   { "Due Upon Receipt" }
  end
end

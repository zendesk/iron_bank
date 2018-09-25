# frozen_string_literal: true

FactoryBot.define do
  factory :new_subscription, class: IronBank::Object do
    account           { build(:account) }
    payment_method    { build(:payment_method) }
    subscription_data { build(:subscription_data) }
  end
end

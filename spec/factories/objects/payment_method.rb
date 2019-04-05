# frozen_string_literal: true

FactoryBot.define do
  factory :payment_method, class: IronBank::Object do
    credit_card_address1         { "312 2nd Ave W" }
    credit_card_city             { "Seattle" }
    credit_card_country          { "United States" }
    credit_card_expiration_month { 12 }
    credit_card_expiration_year  { 2020 }
    credit_card_holder_name      { "Jane Doe" }
    credit_card_number           { "4111111111111111" }
    credit_card_postal_code      { "98119" }
    credit_card_state            { "Washington" }
    credit_card_type             { "Visa" }
    type                         { "CreditCard" }
  end
end

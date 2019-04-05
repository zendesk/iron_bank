# frozen_string_literal: true

FactoryBot.define do
  factory :subscription, class: IronBank::Object do
    auto_renew               { true }
    contract_acceptance_date { Date.parse("22-09-1994").to_s }
    contract_effective_date  { Date.parse("22-09-1994").to_s }
    initial_term             { 1 }
    renewal_term             { 1 }
    service_activation_date  { Date.parse("22-09-1994").to_s }
    term_start_date          { Date.parse("22-09-1994").to_s }
    term_type                { "TERMED" }
  end

  factory :rate_plan, class: IronBank::Object do
    product_rate_plan_id { "1111" }
  end

  factory :rate_plan_charge, class: IronBank::Object do
    product_rate_plan_charge_id { "2222" }
    quantity                    { 4 }
  end

  factory :rate_plan_data, class: IronBank::Object do
    rate_plan { build(:rate_plan) }

    factory :rate_plan_data_with_charges do
      transient do
        charge_count { 1 }
      end

      rate_plan_charge_data do
        create_list(:rate_plan_charge, charge_count)
      end
    end
  end

  factory :subscription_data, class: IronBank::Object do
    transient do
      rate_plan_data_count { 1 }
    end

    subscription { build(:subscription) }

    rate_plan_data do
      create_list(:rate_plan_data_with_charges, rate_plan_data_count)
    end
  end
end

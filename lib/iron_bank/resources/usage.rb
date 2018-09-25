# frozen_string_literal: true

module IronBank
  module Resources
    # Usage is consumed by usage-based charges during the bill run.
    #
    class Usage < Resource
      with_schema

      with_one :account
      with_one :charge, resource_name: 'RatePlanCharge'
      with_one :import
      with_one :subscription
    end
  end
end

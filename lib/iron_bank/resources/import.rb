# frozen_string_literal: true

module IronBank
  module Resources
    # Import usages into Zuora.
    #
    class Import < Resource
      with_schema
      with_many :usages
    end
  end
end

# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora contact, belongs to an account, can be set as the sold to/bill to
    # contact for a given account.
    #
    class Contact < Resource
      with_schema

      with_one :account
    end
  end
end

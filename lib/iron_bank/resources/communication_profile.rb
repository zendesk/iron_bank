# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora communication profile. Controls which notifications (emails and
    # callouts) are sent to a customers and external systems, e.g. provisioning,
    # when events happen for the account, such as invoice posted, subscription
    # created, etc.
    #
    class CommunicationProfile < Resource
      with_schema

      with_many :accounts
      with_many :notifications
    end
  end
end

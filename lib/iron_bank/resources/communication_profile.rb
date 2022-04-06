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
      
      def notifications
        raise IronBank::NotFoundError unless id
  
        response = IronBank.client.connection.get(
          "/settings/communication-profiles/#{id}/notifications"
        )
  
        response.body
      end
    end
  end
end

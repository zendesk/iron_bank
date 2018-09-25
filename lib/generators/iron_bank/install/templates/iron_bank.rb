# frozen_string_literal: true

IronBank.configure do |config|
  # Zuora OAuth client ID
  config.client_id = '<my-client-id-from-zuora>'

  # Zuora OAuth client secret
  config.client_secret = '<my-secret-from-zuora>'

  # Zuora API domain (apisandbox, production, etc.)
  config.domain = 'rest.apisandbox.zuora.com'

  # Directory where the metadata XML files (Zuora schema) will be stored
  config.schema_directory = 'config/zuora/schema'

  # Directory where the local export CSV files will be stored
  config.export_directory = 'config/zuora/local_records'

  # Zuora authentication type:
  #   - `token` uses OAuth and is the *recommended* approach
  #   - `cookie` uses username/password for Zuora environments that do not
  #              support OAuth authentication, e.g., services environment. If
  #              using `cookie` authentication, then use an API user username as
  #              the `client_id` and the API user password as `client_secret`
  config.auth_type = 'token'

  # Set the gem to use the Rails logger
  config.logger = Rails.logger
end

# Iron Bank

[![Build Status][travis-status]][travis-build]

An opinionated Ruby interface to the [Zuora REST API][zuora-dev].

> We who serve the Iron Bank face death full as often as you who serve the Iron
> Throne.

_(A Dance with Dragons, Chapter 44, Jon IX)_

This gem provides opinionated resources to interact with the Zuora API through
their REST interface. It defines **associations** between them, as well as a
simple **declaration API** (`with_one`, `with_many`) to extend them.

This gem is tested against Ruby `>= 2.4`.

Please use [GitHub Issues][issues] to report bugs.

## Getting Started

You will need:

- a **Zuora tenant** (apisandbox, services, performances or production)
- an **administrator access** to this tenant (to gain API access)
- and an **OAuth client** for this user
  ([Zuora documentation][zuora-doc-oauth])

IronBank is a pure Ruby client, but we do provide a generator (for the
configuration) when using it within [Rails][rails-website].

Add the gem to your `Gemfile` with:

```rb
gem 'iron_bank'
```

And run the `bundle` command to install it. You then need to run the generator:

```
$ rails generate iron_bank:install
```

Use the `client_id` and `client_secret` from your Zuora OAuth client and add
them to the generated `config/initializers/iron_bank.rb` file.

## Configuration

```rb
# Configure Ironbank
IronBank.configure do |config|
  config.client_id         = 'client_id'
  config.client_secret     = 'client_secret'
  config.auth_type         = 'auth_type'
  config.domain            = 'zuora-domain'   # zuora doamin
  config.export_directory  = 'directory-path' # export directory path
  config.schema_directory  = 'directory-path' # schema drirectory path

  # Ironbank uses Faraday to send request to Zuora. In order too use custom
  # Faraday middlewares, we can send in an array with cutomer middleware class
  # and options
  config.middlewares << [DummyMiddlewareClass, {}]
end

```

## Usage

```rb
# make a query to Zuora using ZOQL
IronBank::Query.call "select Name from Account where Id='zuora-account-id'"

# retrieve an account
account = IronBank::Account.find 'zuora-account-id'
# => #<IronBank::Resources::Account>

# access this resource attributes
account.name # => 'My Company Inc.'

# or associated objects
account.bill_to
# => #<IronBank::Resources::Contact>

account.active_subscriptions
# => [#<IronBank::Resources::Subscription>]
```

## Local records

If your product catalog does not change often, you may want to export
it locally so that product catalog and related object queries look for
**local records** first, then **fallback** to the API if no records are found.

You can export your product catalog locally using the `LocalRecords` class:

```rb
# Save CSV files in the directory specified by `config.export_directory`
IronBank::LocalRecords.export
```

Then, making a query/looking for a record will first search through the local
records, then default to the API if no records are found.

```rb
product = IronBank::Product.find 'zuora-product-id'
# => #<IronBank::Resources::Product>

product.plans[0].charges[0].tiers[0]
# => #<IronBank::Resources::ProductRatePlanChargeTier>
```

Without local records, the previous scenario will make **4 requests** to Zuora
to access the charge tiers. By exporting local records, you can significantly
reduce your execution time, e.g., when building a `SubscriptionRequest`.

## Development

1. After checking out the repo, run `bin/setup` to install dependencies
2. Edit the copied `.env` file with your Zuora credentials
3. Execute `bundle exec rake` to run the linters and tests
4. You can also run `bin/console` for an interactive prompt that will allow you
   to experiment with the Zuora APIs

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/zendesk/iron_bank.

## Known issues

- `AutoPay` field on the `Invoice` object is not queryable using ZOQL despite
  the metadata showing `<selectable>true</selectable>`, hence it has been added
  to the `exclude_fields` method.

## Copyright and license

Copyright 2018 Zendesk, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.

You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

[issues]: https://github.com/zendesk/iron_bank/issues
[travis-status]: https://travis-ci.com/zendesk/iron_bank.svg?token=Qzkq5papoR7sdedznjeb&branch=master
[travis-build]: https://travis-ci.com/zendesk/iron_bank
[zuora-describe]: https://www.zuora.com/developer/api-reference/#tag/Describe
[zuora-dev]: https://developer.zuora.com
[zuora-doc-oauth]: https://knowledgecenter.zuora.com/CF_Users_and_Administrators/A_Administrator_Settings/Manage_Users#Create_an_OAuth_Client_for_a_User
[zuora-website]: https://www.zuora.com
[rails-website]: https://rubyonrails.org/

# frozen_string_literal: true

require 'rails/generators/base'

module IronBank
  module Generators
    # Allow us to run `rails generate iron_bank:install`
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_iron_bank_initializer
        copy_file 'iron_bank.rb', 'config/initializers/iron_bank.rb'
      end

      def display_readme_in_terminal
        readme 'README'
      end
    end
  end
end

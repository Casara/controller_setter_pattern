require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
]
SimpleCov.start do
  add_filter '/spec/' # Do not include spec files in coverage
end

# Core Rails requirements
require 'rails'
require 'action_controller/railtie'
require 'active_record/railtie'

# Test-specific gems
require 'rails-controller-testing' # Essential for controller specs (assigns, assert_template)
require 'database_cleaner'
require 'logger'
require 'faker'
require 'factory_bot_rails'
require 'rspec/rails' # Includes RSpec core and Rails integration

# Gem under test
require 'controller_setter_pattern'

# Define a minimal Rails application for testing controller specs
module Rails
  class App < ::Rails::Application
    config.root = File.expand_path('..', __dir__) # Project root
    # Load routes for the test application
    config.paths['config/routes.rb'] = [File.expand_path('support/routes.rb', __dir__)]
    # Minimal other configs that might be necessary for ActionController::Base to operate
    config.eager_load = false # Typical for test/dev
    config.secret_key_base = 'dummy_secret_key_base_for_controller_setter_pattern_specs_0123456789abcdef'
    # If specific middleware is needed by controller specs beyond defaults, add here.
    # For basic controller specs, often not much is needed beyond what AC::Base pulls in.
  end

  # Singleton for the application instance
  def self.application
    @application ||= App.new
    # No explicit initialize! here; rspec-rails handles controller spec lifecycle.
    # Forcing full initialization here caused issues with request specs before.
    # Controller specs are more lightweight.
  end
end

# Initialize the application so routes are loaded and available.
# This ensures Rails.application.routes is populated.
Rails.application.routes_reloader.reload! if Rails.application.respond_to?(:routes_reloader)

# ActiveRecord setup
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.verbose = false # Suppress migration output
ActiveRecord::Base.logger = Logger.new(IO::NULL) # Suppress AR logging

# Load schema, models, and test controllers
load File.expand_path('support/schema.rb', __dir__)
require_relative 'support/models'
require_relative 'support/controllers' # Defines dummy controllers

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  # Include necessary RSpec-Rails helpers
  config.include Rails.application.routes.url_helpers # Make route helpers available
  # For controller specs (`type: :controller`), `assigns` and template assertions
  # should be available automatically when `rails-controller-testing` is bundled
  # and `rspec-rails` is configured. Explicitly including these modules from
  # ActionController::Testing can sometimes cause issues or be redundant.
  # config.include ActionController::Testing::Assigns
  # config.include ActionController::Testing::TemplateAssertions

  # For controller specs, ensure routes are loaded into the test context
  config.before(:each, type: :controller) do
    # Draw routes for each controller spec, as they are isolated tests
    # This ensures that `get :action` can find the route.
    # Note: Rails.application should be the minimal app defined above.
    Rails.application.routes.draw do
      get 'user/(:id)' => 'users#show'
      get 'users_ping' => 'users#ping' # New route
      get 'resend_password/:email' => 'account#resend_password'
      get 'profile/:username' => 'account#profile'
      get 'admin/profile/:username' => 'account#admin_profile', as: :admin_profile
      get 'customers/:customer_id/orders/:id' => 'orders#show'
      get 'customers/:customer_id/orders/:id/edit' => 'orders#edit', as: :edit_customer_order # Named for clarity
      get 'order_by_customer_date' => 'orders#order_by_customer_date'
      get 'suppliers/:supplier_id/accounts/:id' => 'accounts#show'
    end
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    FactoryBot.find_definitions # Ensure factories are found
    # FactoryBot.lint # Optional, can be slow
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
]
SimpleCov.start do
  add_filter '/spec/' # Do not include spec files in coverage
  # add_filter '/vendor/' # Example: if there were vendored gems
end

require 'rails-controller-testing'
require 'action_controller/railtie'
require 'action_controller'
require 'active_model'
require 'active_record'
require 'database_cleaner'
require 'logger'
require 'faker'
require 'factory_bot_rails'
require 'rspec/rails'
require 'rails'
# Note: controller_setter_pattern should be required AFTER SimpleCov.start
# to ensure its loading is tracked for coverage.
require 'controller_setter_pattern'

module Rails
  class App < Rails::Application
    def env_config; {} end

    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new
    end

    config.root = File.expand_path('../../', __FILE__)
  end

  def self.application
    @app ||= App.new
  end
end

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), '../log/debug.log'))

# now that we have the database configured, we can create the models and
# migrate the database
require 'support/models'
require 'support/controllers'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.start
      FactoryBot.find_definitions
      FactoryBot.lint
    ensure
      DatabaseCleaner.clean
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
require 'action_controller'
require 'active_model'
require 'active_record'
require 'database_cleaner'
require 'logger'
require 'faker'
require 'factory_girl_rails'
require 'codeclimate-test-reporter'

formatters = [SimpleCov::Formatter::HTMLFormatter]
formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
SimpleCov.start

require 'controller_setter_pattern'

module Rails
  class App
    def env_config; {} end
    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new
    end
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
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.start
      FactoryGirl.find_definitions
      FactoryGirl.lint
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
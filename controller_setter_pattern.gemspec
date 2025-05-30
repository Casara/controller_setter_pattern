$:.push File.expand_path('../lib', __FILE__)

require 'controller_setter_pattern/version'

Gem::Specification.new do |s|
  s.name        = 'controller_setter_pattern'
  s.version     = ControllerSetterPattern::VERSION
  s.authors     = ['Rodrigo Casara']
  s.email       = ['rodrigocasara@gmail.com']
  s.homepage    = 'https://github.com/Casara/controller_setter_pattern'
  s.summary     = 'Pattern for assign instance variables in controllers for use in views, etc.'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 3.13', '>= 3.13.1'
  s.add_development_dependency 'rspec-rails', '~> 8.0'
  s.add_development_dependency 'rails-controller-testing', '~> 1.0' # Add rails-controller-testing
  s.add_development_dependency 'sqlite3' # TODO: Check compatibility with Rails 8
  s.add_development_dependency 'database_cleaner', '~> 2.1' # TODO: Check compatibility with Rails 8
  s.add_development_dependency 'rake' # TODO: Check compatibility with Rails 8
  s.add_development_dependency 'simplecov', '~> 0.22.0' # Or a more recent compatible version
  s.add_development_dependency 'simplecov-lcov', '~> 0.8.0'
  s.add_development_dependency 'actionpack', '~> 8.0', '>= 8.0.2'
  s.add_development_dependency 'activesupport', '~> 8.0', '>= 8.0.2'
  s.add_development_dependency 'faker', '~> 3.5', '>= 3.5.1'
end
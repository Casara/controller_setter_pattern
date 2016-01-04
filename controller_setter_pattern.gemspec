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

  s.add_development_dependency 'rspec', '~> 3.4.0'
  s.add_development_dependency 'rspec-rails', '~> 3.4.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'database_cleaner', '~> 1.5.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'actionpack', '~> 4.2.5'
  s.add_development_dependency 'activesupport', '~> 4.2.5'
  s.add_development_dependency 'factory_girl_rails', '~> 4.5.0'
  s.add_development_dependency 'faker', '~> 1.6.1'
end
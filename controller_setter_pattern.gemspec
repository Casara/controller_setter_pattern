$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'controller_setter_pattern/version'

Gem::Specification.new do |s|
  s.name        = 'controller_setter_pattern'
  s.version     = ControllerSetterPattern::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Rodrigo Casara']
  s.email       = ['rodrigocasara@gmail.com']

  s.summary     = 'Eliminate boilerplate setter and before_action code in controllers'
  s.description = 'A lib used to easily generate setter and before_action in controllers.'
  s.homepage    = 'https://github.com/Casara/controller_setter_pattern'
  s.license     = 'MIT'

  s.files         = Dir['lib/**/*'] + %w[LICENSE CHANGELOG.md README.md]
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.4'

  s.metadata['changelog_uri'] = 'https://github.com/Casara/controller_setter_pattern/blob/main/CHANGELOG.md'
  s.metadata['source_code_uri'] = 'https://github.com/Casara/controller_setter_pattern'
  s.metadata['bug_tracker_uri'] = 'https://github.com/Casara/controller_setter_pattern/issues'
  s.metadata['documentation_uri'] = 'https://rubydoc.info/github/Casara/controller_setter_pattern'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.add_dependency 'rails', '>= 8.0'
  # NOTE: Development dependencies were previously here, but are now expected to be managed via Gemfile's group.
  # If any are still needed for the gem's own development tasks when used as a standalone project,
  # they should be re-added here (e.g., s.add_development_dependency for rspec, rubocop etc.)
  # Based on the new Gemfile, it seems they are fully managed there.
end

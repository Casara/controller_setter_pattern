# Justfile for controller_setter_pattern

# Default task: list available commands or run tests
default: test

# Setup development environment
setup:
    bundle install

# Run RSpec tests
test:
    bundle exec rspec

# Run a Ruby console session
console:
    bundle exec irb

# Run RuboCop to check for offenses
lint:
    bundle exec rubocop

# Auto-correct offenses with RuboCop
format:
    bundle exec rubocop -A

# List available tasks (simple version)
list:
    @echo "Available tasks:"
    @echo "  setup    - Install dependencies"
    @echo "  test     - Run RSpec tests"
    @echo "  console  - Start IRB console"
    @echo "  lint     - Run RuboCop to check for offenses"
    @echo "  format   - Auto-correct offenses with RuboCop"
    @echo "  list     - List available tasks"

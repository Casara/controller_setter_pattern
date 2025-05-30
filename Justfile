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

# Placeholder for linter (e.g., RuboCop)
lint:
    echo "Linter not yet configured. Add RuboCop or other linter."

# List available tasks (simple version)
list:
    @echo "Available tasks:"
    @echo "  setup    - Install dependencies"
    @echo "  test     - Run RSpec tests"
    @echo "  console  - Start IRB console"
    @echo "  lint     - Run linter (not yet configured)"
    @echo "  list     - List available tasks"

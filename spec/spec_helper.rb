require 'bundler/setup'
require 'documentary'
require 'action_controller'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Test controller to emaulte a class in which
# Documentary::Params can be mixed in
class TestController < ActionController::Base
  include Documentary::Params
  def show; end
end

require 'bundler/setup'
require 'byebug'
require 'dashbeautiful'

# loads all the fixtures under spec/fixtures/*.yml creates methods based on
# file names, so spec/fixtures/data.yml creates method data_fixture
# which can be used from tests
def load_fixtures
  Dir['./spec/fixtures/*'].each do |file|
    define_method "#{File.basename(file, '.yml')}_fixture".to_sym do
      YAML.load_file(file)
    end
  end
end

def api_double(key: 'test-double-key', organizations: [])
  double('Dashbeautiful::API',
         key: key,
         organizations: organizations)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  load_fixtures
end

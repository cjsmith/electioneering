require 'capybara/dsl'
require 'database_cleaner'
require 'steak'

RSpec.configure do |config|
  config.include Capybara

  config.before(:suite, :type => :acceptance ) do
    DatabaseCleaner.strategy = :truncation, {:except => ['candidates','polls']}
  end

  config.before(:each, :type => :acceptance) do
    DatabaseCleaner.clean
  end

end

app_file = File.join(File.dirname(__FILE__), '..', '..', 'electioneering.rb')
require app_file
Sinatra::Application.app_file = app_file
Sinatra::Application.set :logging, false
Capybara.app = Sinatra::Application
Capybara.default_driver = :selenium
Capybara.save_and_open_page_path = '/tmp'

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each {|f| require f}


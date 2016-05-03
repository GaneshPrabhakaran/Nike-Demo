source 'http://rubygems.org'

group :desktop do
  gem 'gmail', '0.5.0'
  if (RUBY_PLATFORM =~ /w32/) # windows
    gem 'au3', '0.1.2'
  end
end

group :appium do
  gem 'appium_lib', '5.0.1'
  gem 'sauce_whisk', '0.0.13'
end

group :mew do
  # TESTING FRAMEWORK
  gem 'selenium-client'
  gem 'hashie'
  # SUPPORT
  gem 'rubyntlm'
  # DEBUGGING
  gem 'crb'
  gem 'parallel_tests'
end

group :ios_app do
  # NOTHING UNIQUE HERE YET
end

group :android_app do
  gem 'calabash-android',     '~>0.5.2'
end

group :calabash_cucumber do
  gem 'calabash-cucumber',    '0.14.3'
end

group :tablet do
  # NOTHING UNIQUE HERE YET
end

# Page Object gems
gem 'page-object', '0.9.2'
gem 'page_navigation', '0.9'
gem 'data_magic', '0.15.2'

# Cucumber gems
gem 'versionone_sdk', '~>0.1'
gem 'cucumber', '1.3.17'
gem 'gherkin', '2.12.2'
gem 'cucumber_analytics', '1.5.1'   # Duplicate scenario name testing
gem 'cuke_sniffer', '0.0.7'         # TODO: used?
gem 'slowhandcuke', '0.0.3'         # TODO: used?
gem 'roodi', '4.0.0'                # Ruby static analysis testing

# Core Metrics testing / network debugging
gem 'browsermob-proxy', '0.1.8'
gem 'har', '0.0.9'

# Framework - logging, screenshots, rake tasks, data access layer
gem 'logger', '1.2.8'
gem 'activerecord', '4.0.0'
#gem 'activerecord-jdbc-adapter', '1.3.2'
#gem 'activerecord-jdbcsqlite3-adapter', '1.3.2'
gem 'activerecord-oracle_enhanced-adapter', '1.5.1'
gem 'win32screenshot', '1.0.10'
gem 'rake', '0.9.2.2'
gem 'require_all', '1.2.1'
gem 'selenium-webdriver', '~>2.45.0' #added to beta
gem 'nokogiri', '1.6.3.1' #added to beta
gem 'headless', '2.2.0'



# TODO: Clean up this list.  This list should only contain high-level gems required by
# the test framework.  Gem dependencies should be managed by bundler, and should be committed
# in the Gemfile.lock file.
gem 'aes'
gem 'rautomation'
gem 'CFPropertyList', '2.2.1'
gem 'i18n', '0.6.5'
gem 'minitest', '4.7.5'
gem 'multi_json', '1.7.9'
gem 'json', '1.8.1' #added to beta
gem 'atomic', '1.1.13'
gem 'thread_safe', '0.1.2'
gem 'tzinfo', '0.3.37'
gem 'activesupport', '4.0.0', require: 'active_support/all'
gem 'addressable', '2.3.5'
gem 'builder', '3.1.0'
gem 'gyoku', '1.1.0'
gem 'akami', '1.2.0'
gem 'ffi', '1.9.6'
gem 'childprocess', '0.5.1'
gem 'jschematic', '0.1.0'
gem 'launchy', '2.3.0'
gem 'mime-types', '1.24'
gem 'rest-client', '1.6.7'
gem 'diff-lcs', '1.1.3'
gem 'calabash-common', '0.0.1'
gem 'parslet', '1.4.0'
gem 'edn', '1.0.6'
gem 'httpclient', '2.3.4.1'
gem 'geocoder', '1.1.8'
gem 'location-one', '0.0.10'
gem 'thor', '0.18.1'
gem 'run_loop', '1.3.3'
gem 'rack', '1.5.2'
gem 'rack-protection', '1.5.0'
gem 'tilt', '1.4.1'
gem 'sinatra', '1.4.3'
gem 'sim_launcher', '0.4.13'
gem 'rack-test', '0.6.2'
gem 'websocket', '1.0.7'
gem 'xpath', '0.1.4'
gem 'roxml', '3.3.1'
gem 'faker', '1.2.0'
gem 'yml_reader', '0.2'
gem 'multi_xml', '0.5.5'
gem 'httparty', '0.10.0'
gem 'httpi', '2.2.3'
#gem 'jruby-pageant', '1.1.1'
gem 'systemu', '2.5.2'
gem 'macaddr', '1.6.1'
gem 'net-http-persistent', '2.9'
gem 'net-ssh', '2.6.8'
gem 'net-ssh-gateway', '1.2.0'
gem 'nori', '2.4.0'
gem 'random_data', '1.6.0'
gem 'rspec-core', '2.12.2'
gem 'rspec-expectations', '2.12.1'
gem 'rspec-mocks', '2.12.2'
gem 'rspec', '2.12.0'
gem 'wasabi', '3.3.0'
gem 'savon', '2.6.0'
gem 'syntax', '1.0.0'
gem 'uuid', '2.3.7'
gem 'yard', '0.8.7'
gem 'ibm_db'
gem 'ruby-oci8'
gem 'pry'
gem 'pry-byebug'
gem 'countries', '0.11.1'
#gem 'ruby-debug' unless ENV['RM_INFO'] # This gem is incompatible with RubyMine debugging
gem 'geokit'
gem 'memoist'
gem 'ruby_parser',          '3.6.5'  #3.6.6 breaks our builds with parser error
gem 'htmlentities', '4.3.3' # HTML character encoding in Cucumber.
gem 'chunky_png', '1.3.4'
require 'bundler/setup'
Bundler.require :default

require 'win32/screenshot' if ExecutionEnvironment.host_os == :windows
#require 'vendor/jars/db2driver-9.5.jar'
#require 'vendor/jars/ojdbc14.jar'
#require 'vendor/jars/mysql-connector-java-5.0.8-bin.jar'

require_all 'lib/utils'

BEGIN {
  # The log directory creation is done in a BEGIN clause, otherwise the cucumber gem will complain
  # about a missing 'log' directory.
  require_relative '../../lib/utils/execution_environment'
  Dir.mkdir(ExecutionEnvironment.log_directory) unless Dir.exists?(ExecutionEnvironment.log_directory)
}
if ENV['IOS_CALABASH'] == nil
  World(PageObject::PageFactory)
end
World(SiteSelector)

raise "URL parameter is required." unless ENV['URL']

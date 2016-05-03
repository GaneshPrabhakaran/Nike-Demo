Bundler.require :mew, :default, :appium

# TODO: need to remove this in the future and require it manually, need to require ruby files
require File.expand_path('support/mobile_website/mobile_device')
require File.expand_path('support/mobile_website/mobile_browser')

# Loads the .rb files inside initializers
Dir.glob('./initializers/*.rb').each do |init_file|
  eval(IO.read(init_file), binding)
end

# Need to set default values before requiring page objects that are using expected_element
PageObject.default_element_wait = 20
PageObject.default_page_wait = 60

require_all 'lib/mobile_website'

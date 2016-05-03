#$LOAD_PATH << File.expand_path('../common', File.dirname(__FILE__))

# Need to set default values before requiring page objects that are using expected_element
PageObject.default_element_wait = 10
PageObject.default_page_wait = 60

require_all 'lib/website'

World(Browser)

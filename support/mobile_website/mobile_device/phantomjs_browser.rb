class MobileDevice::PhantomjsBrowser < MobileDevice::Base
  # Requires you to install the following in your system
  # brew install selenium-server-standalone
  #
  # You also require phantomjs to be installed
  # brew install phantomjs
  #
  # Please start your phantomjs on the same port
  # phantomjs --webdriver 22222

  def perform
    Selenium::WebDriver.for :phantomjs, url: 'http://localhost:22222'
  end
end

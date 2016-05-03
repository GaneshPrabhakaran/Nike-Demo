class MobileDevice::OperaBrowser < MobileDevice::Base
  def perform
    # Requires you to install the following in your system
    # brew install selenium-server-standalone

    Selenium::WebDriver.for :remote, url: 'http://127.0.0.1:4444/wd/hub', desired_capabilities: Selenium::WebDriver::Remote::Capabilities.opera
  end
end

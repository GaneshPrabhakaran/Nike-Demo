class MobileDevice::ChromeBrowser < MobileDevice::Base
  def perform
    caps = Selenium::WebDriver::Remote::Capabilities.chrome
    @browser = Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: proxy
  end
end

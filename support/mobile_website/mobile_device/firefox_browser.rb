class MobileDevice::FirefoxBrowser < MobileDevice::Base
  def perform
    caps = Selenium::WebDriver::Remote::Capabilities.firefox
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = start_proxy if ExecutionEnvironment.proxy_enabled?
    @browser = Selenium::WebDriver.for :firefox, desired_capabilities: caps, profile: profile
  end
end

class MobileDevice::ChromeSamsungS4 < MobileDevice::Base
  def perform
    mobile_emulation = { 'deviceName' => 'Samsung Galaxy S4' }
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'mobileEmulation' => mobile_emulation })
    @browser = Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: proxy
    @browser.manage.window.size = Selenium::WebDriver::Dimension.new(360, 640)
    @browser
  end
end

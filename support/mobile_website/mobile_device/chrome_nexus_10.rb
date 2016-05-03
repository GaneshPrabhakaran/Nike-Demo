class MobileDevice::ChromeNexus10 < MobileDevice::Base
  def perform
    mobile_emulation = { 'deviceName' => 'Google Nexus 10' }
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'mobileEmulation' => mobile_emulation })
    @browser = Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: proxy, args: ['--window-size=805,1285']
  end
end

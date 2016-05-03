class MobileDevice::Iphone < MobileDevice::Base
  def desired_capabilities
    # if UDID is not found, appium will run the test through iPhoneSimulator
    fail ArgumentError, 'UDID parameter not found' if ENV['UDID'].blank?

    Selenium::WebDriver::Remote::Capabilities.iphone(browserName: 'safari',
                                                     deviceName: 'iPhone Retina 4-inch',
                                                     udid: ENV['UDID'],
                                                     newCommandTimeout: 9999,
                                                     platformName: 'iOS')
  end

  def url
    'http://127.0.0.1:4723/wd/hub'
  end
end

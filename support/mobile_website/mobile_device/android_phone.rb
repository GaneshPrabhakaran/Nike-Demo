class MobileDevice::AndroidPhone < MobileDevice::Base
  def desired_capabilities
    Selenium::WebDriver::Remote::Capabilities.android(deviceName: 'Android',
                                                      browserName: 'chrome',
                                                      platformName: 'Android',
                                                      newCommandTimeout: 9000)
  end

  def url
    'http://127.0.0.1:4723/wd/hub'
  end

  def teardown
    `pkill chromedriver`
  end
end

class MobileDevice::IpadSimulator < MobileDevice::Base
  def desired_capabilities
    Selenium::WebDriver::Remote::Capabilities.iphone(browserName: 'safari',
                                                     deviceName: 'iPad Simulator',
                                                     platformName: 'iOS',
                                                     safariAllowPopups: true,
                                                     newCommandTimeout: 9999)
  end

  def url
    'http://127.0.0.1:4723/wd/hub'
  end

  def reset_cookies?
    # Need to always set this to true due to SafariDriver not having access to cookie jar
    true
  end
end

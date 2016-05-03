class MobileDevice::SafariBrowser < MobileDevice::Base
  # Requires you to install the following in your system
  # brew install selenium-server-standalone

  def perform
    Selenium::WebDriver.for :safari, url: 'http://127.0.0.1:4444/wd/hub'
  end

  def reset_cookies?
    # Need to always set this to true due to SafariDriver not having access to cookie jar
    true
  end
end

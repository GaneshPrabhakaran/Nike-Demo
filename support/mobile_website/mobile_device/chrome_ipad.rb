class MobileDevice::ChromeIpad < MobileDevice::Base
  def perform
    # TODO: CHROME DEVICE MODE CURRENTLY HAS ISSUES WITH ANYTHING OVER IOS4
    mobile_emulation = {
      'deviceMetrics' => { 'width' => 768, 'pixelRatio' => 2.0 },
      'userAgent' => 'Mozilla/5.0 (iPad; CPU OS 4_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53'
    }
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'mobileEmulation' => mobile_emulation })
    @browser = Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: start_proxy, args: ['--window-size=769,1102']
  end
end

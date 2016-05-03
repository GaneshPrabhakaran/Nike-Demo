class MobileDevice::ChromeIphone < MobileDevice::Base
  def perform
    # TODO: CHROME DEVICE MODE CURRENTLY HAS ISSUES WITH ANYTHING OVER IOS4
    mobile_emulation = {
      'deviceMetrics' => { 'width' => 375, 'height' => 627, 'pixelRatio' => 2.0 },
      'userAgent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 4_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4'
    }
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'mobileEmulation' => mobile_emulation })

    # TODO: run extensions by passing extra args, e.g: '--load-extension=/Users/m448385/Library/Application Support/Google/Chrome/Default/Extensions/fngmhnnpilhplaeedifhccceomclgfbg/1.4.1_0'
    @browser = Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: start_proxy, args: ['--window-size=376,705']
  end
end

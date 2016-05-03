class MobileDevice::ChromeIphone6 < MobileDevice::Base
  def perform
    mobile_emulation = {
      'deviceMetrics' => { 'width' => 375, 'height' => 627, 'pixelRatio' => 2.0, 'touch' => false },
      'userAgent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'
    }
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'mobileEmulation' => mobile_emulation })

    # TODO: run extensions by passing extra args, e.g: '--load-extension=/Users/m448385/Library/Application Support/Google/Chrome/Default/Extensions/fngmhnnpilhplaeedifhccceomclgfbg/1.4.1_0'
    @browser = Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: start_proxy, args: ['--window-size=376,705']
  end
end

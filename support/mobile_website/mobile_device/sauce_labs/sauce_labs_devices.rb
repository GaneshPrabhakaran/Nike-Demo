require 'json'

class MobileDevice::SauceLabsDevices < MobileDevice::Base
  def desired_capabilities
    case ENV['DEVICE'].downcase.gsub('sauce', '').partition('_').first
    when 'galaxys4'
      {
        browserName: 'chrome',
        platformName: 'Android',
        platformVersion: '4.4',
        deviceName: 'Samsung Galaxy S4 Device',
        deviceType: 'phone'
      }
    when 'galaxys5'
      {
        browserName: 'chrome',
        platformName: 'Android',
        platformVersion: '4.4',
        deviceName: 'Samsung Galaxy S5 Device',
        deviceType: 'phone'
      }
    when 'android'
      {
        browserName: 'browser',
        platformName: 'Android',
        platformVersion: ENV['DEVICE'].downcase.gsub('sauce', '').partition('_').last,
        deviceName: 'Android Emulator'
      }
    when 'ios'
      {
        browserName: 'Safari',
        platformVersion: ENV['DEVICE'].downcase.gsub('sauce', '').partition('_').last,
        platformName: 'iOS',
        deviceName: 'iPhone Simulator'
      }
    when 'androidtablet'
      {
        browserName: 'browser',
        platformName: 'Android',
        platformVersion: ENV['DEVICE'].downcase.gsub('sauce', '').partition('_').last,
        deviceName: 'Android Emulator',
        deviceType: 'tablet'
      }
    when 'ipadsim'
      {
        browserName: 'Safari',
        platformName: 'iOS',
        platformVersion: '9.0',
        deviceName: 'iPad Retina',
        deviceOrientation: 'portrait',
        deviceType: 'tablet'
      }
    when 'galaxy10'
      {
        browserName: 'browser',
        platformName: 'Android',
        platformVersion: '4.1',
        deviceName: 'Samsung Galaxy Note 10.1 Emulator',
        deviceType: 'tablet'
      }
    when 'nexus7'
      {
        browserName: 'browser',
        platformName: 'Android',
        platformVersion: '4.4',
        deviceName: 'Google Nexus 7 HD Emulator',
        deviceType: 'tablet'
      }
    when 'iphonesim'
      {
        browserName: 'Safari',
        platformName: 'iOS',
        platformVersion: '9.0',
        deviceName: 'iPhone 6',
        deviceOrientation: 'portrait'
      }

    when 'iphone6'
      {
        browserName: 'Safari',
        platformName: 'iOS',
        platformVersion: '8.4',
        deviceName: 'iPhone 6 Device',
        deviceOrientation: 'portrait'
      }
    else
      fail ArgumentError, "'#{ENV['DEVICE']}' is not a valid device!"
    end
  end

  # no longer needed when using appium_lib gem, but saving for reference
  # def url
  #  'http://' + ENV['SAUCE_USERNAME'] + ':' + ENV['SAUCE_ACCESS_KEY'] + '@ondemand.saucelabs.com:80/wd/hub'
  # end

  def perform(_scenario = nil)
    runDetails =
      {
        jenkinsBuildURL: ENV['BUILD_URL']
      }

    desired_caps = desired_capabilities.merge!(name: $scenario.name, customData: runDetails) # , customData: runDetails.to_json)

    Appium::Driver.new(caps: desired_caps).start_driver
    Appium.promote_appium_methods Object
    @browser = $driver.driver
  end
end

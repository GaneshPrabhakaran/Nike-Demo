class MobileDevice::Nexus6emu < MobileDevice::Base
  EMULATOR_NAME = 'Nexus6'.freeze

  def desired_capabilities
    Selenium::WebDriver::Remote::Capabilities.android(browserName: 'browser',
                                                      deviceName: EMULATOR_NAME,
                                                      platformName: 'android',
                                                      platformVersion: '5.1.1',
                                                      newCommandTimeout: 9999,
                                                      autoAcceptAlerts: true)
  end

  def perform(_scenario = nil)
    Log.instance.info "Booting emulator #{EMULATOR_NAME}"

    system "/Users/$USER/android-sdk-macosx/tools/emulator -avd #{EMULATOR_NAME} -scale 0.3 > log/emulator.log &"

    timeout = 60

    begin
      Timeout.timeout(timeout) do
        i = 0
        until `/Users/$USER/android-sdk-macosx/platform-tools/adb shell getprop init.svc.bootanim`.include?('stopped')
          i += 1
          Log.instance.info "Waiting #{i} seconds for #{EMULATOR_NAME} to boot"
          sleep 1
        end
      end
    rescue Timeout::Error => e
      raise e, "Booting emulator '#{EMULATOR_NAME}' took over #{timeout} seconds."
    end

    Appium::Driver.new(caps: desired_capabilities).start_driver
    Appium.promote_appium_methods Object
    @browser = $driver.driver
  end
end

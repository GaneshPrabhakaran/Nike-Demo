Before('~@no_browser') do |scenario|
  $scenario = scenario
  start_appium if ExecutionEnvironment.appium?
  kill_emulator if ExecutionEnvironment.appium?
  @browser ||= MobileBrowser.start

  Log.instance.info 'Sauce ID:  ' + @browser.capabilities['webdriver.remote.sessionid'] if ExecutionEnvironment.sauce?

  # TODO: Is this needed?
  browser_cookies = Cookies.new(@browser)
  browser_cookies.delete_user_session_cookies
  # This prevents a foresee popup to supply feedback.
  browser_cookies.mew_disable_foresee
  # This disables all experiments
  browser_cookies.create(name: 'SEGMENT', value: '%7B%22EXPERIMENT%22%3A%5B%5D%7D', domain: URI.parse(ExecutionEnvironment.url).host.gsub('m.', ''), path: '/')
  browser_cookies.update_segment_cookie_experiments(ExecutionEnvironment.experiments) if ExecutionEnvironment.experiments
end

After('~@no_browser') do |scenario|
  set_sauce_info(scenario) if ExecutionEnvironment.sauce?
  kill_appium if ExecutionEnvironment.appium?
  kill_emulator if ExecutionEnvironment.appium?
end

AfterConfiguration do
end

def set_sauce_info(scenario)
  scenario.failed? ? (SauceWhisk::Jobs.fail_job (@driver.nil? ? @browser.capabilities['webdriver.remote.sessionid'] : @driver.session_id)) : (SauceWhisk::Jobs.pass_job (@driver.nil? ? @browser.capabilities['webdriver.remote.sessionid'] : @driver.session_id))
end

def take_browser_screenshot_with_exception(exception = nil, error_msg = '')
  unless error_msg.empty?
    error_msg += (exception.nil? ? ' ' : ' and Exception: ')
  end
  error = exception.nil? ? (error_msg + 'Screenshot') : (error_msg + exception.to_s + '<br>' + exception.backtrace[0..4].join('<br>') + '<br>')

  # The error screenshot count is here for tests that support capturing multiple errors and exceptions.
  # The error count is unique for each scenario.
  @error_screenshot_counter = 0 if @error_screenshot_counter.nil?
  @error_screenshot_counter += 1
  timestamp = Time.now.strftime('%Y_%m_%d-%HH_%MM_%SS_%LS')
  take_browser_screenshot("screenshot_#{timestamp}.png", "Error #{@error_screenshot_counter} - " + error)
end

def start_appium
  kill_appium
  Log.instance.info 'Starting Appium session'
  system "appium --session-override > log/appium.log &"
end

def kill_appium
  Log.instance.info 'Killing any existing Appium session'
  system "kill $(ps -fe | grep '[a]ppium' | awk '{print $2}')"
end

def kill_emulator
  Log.instance.info 'Killing any existing emulator sessions'
  (5554..5584).each do |n|
    system "/Users/$USER/android-sdk-macosx/platform-tools/adb -s emulator-#{n} emu kill " if n.even? && (system "nc -z localhost #{n}")
  end
end

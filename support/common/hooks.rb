require 'benchmark'
 require 'timeout'
require 'headless'

Before do |scenario, tags|
  if !ENV["HEADLESS"].nil?
    @headless = Headless.new
    @headless.start
  end

  @scenario_uuid = UUID.new.generate
  @log = Log.instance.start_new(ExecutionEnvironment.log_directory)
  # We inject cucumber world into log class to get INFO trace in our cucumber reports.
  @log.instance_variable_set(:@cucumber_world, self)
  @log.level = ENV['LOG_SEVERITY'].nil? ? Logger::DEBUG : eval("Logger::#{ENV['LOG_SEVERITY']}")

  @log.debug "ID:        #{@scenario_uuid}"
  @log.debug "Scenario:  #{scenario.name}"
  @log.debug "URL:       #{ExecutionEnvironment.url}"
  @log.debug "Test Host: #{ExecutionEnvironment.host_os} #{ExecutionEnvironment.host_address}"
  @log.debug "Grid Hub:  #{ExecutionEnvironment.selenium_grid_hub}"
  @log.debug "Browser:   #{ExecutionEnvironment.browser_name} #{ExecutionEnvironment.browser_version} #{ExecutionEnvironment.browser_os}"
  @log.debug ""

  ActiveRecord::Base.logger = @log
  #TestData.instance.reset
  @common_step_index = 0
end

AfterStep do |scenario|
  if ExecutionEnvironment.browser_name != :none
    current_url = @browser.current_url rescue 'Unable to retrieve the current url'
  end

  step = scenario.respond_to?('raw_steps') ? scenario.raw_steps[@common_step_index] :
      scenario.scenario_outline.raw_steps[@common_step_index]

  log_statement = "Step complete: #{step.name}\".\n\tEnding URL: #{current_url}"
  if step.respond_to? 'location'
    log_statement = log_statement + "\n\tLocation: #{step.location}"
  end

  @log.debug log_statement
  @log.debug ''
  @common_step_index += 1
end

# Important - the After step should not throw any errors.  Verify the @browser instance is not nil
# before using it, catch any errors thrown from taking screenshots, etc.
After do |scenario|
  @log.error "Exception: #{scenario.exception}\n" + scenario.exception.backtrace.join("\n") if scenario.failed? and not @logged_failure_exception
  @log.debug ''
  @log.debug "Finished Scenario: #{scenario.name}"
  @log.debug "Status: #{scenario.status}"

  screenshot = take_browser_screenshot if (@browser || ExecutionEnvironment.calabash?) && scenario.failed?
  cleanup_browser if (@browser || ENV["HEADLESS"].nil? || ExecutionEnvironment.calabash?)

  test_log = File.basename(Log.instance.log_file_path)
  embed(test_log, 'text/plain', 'Cucumber Log File') rescue nil

  # Version One reporting
  if ENV['PUBLISH_V1_RESULTS']
    log_dir = "#{ENV['BUILD_URL']}artifact/log"
    triage_links = {}
    triage_links['Cucumber report'] = "#{log_dir}/cucumber.html"
    triage_links['Screenshot']      = "#{log_dir}/#{File.basename screenshot}" if screenshot
    triage_links['Test log']        = "#{log_dir}/#{File.basename test_log}"

    begin
      VersionOneReporter.report_result(scenario, triage_links)
    rescue => e
      @log.error "Encountered an error when reporting results to VersionOne: #{e.class}: #{e.message}"
    end
  end

  if ExecutionEnvironment.proxy_enabled?('CoreMetrics')
    passed,expect,actual,diff = ::AnalyticsObserver.instance.update(:verify_analytics,scenario.name)
    path_ext = ExecutionEnvironment.user_running_test? ? '' : '/*view*/'
    embed(File.basename(expect) + path_ext, 'text/plain', 'Expected Coremetrics YAML') if expect
    embed(File.basename(actual) + path_ext, 'text/plain', 'Actual Coremetrics YAML') if actual
    embed(File.basename(diff) + path_ext, 'text/plain', 'Differences Coremetrics YAML') if diff
    raise "Coremetrics Evaluation Failed! Details are in 'Differences Coremetrics YAML'" unless passed
  end

  if ExecutionEnvironment.proxy_enabled?('CM2')
    begin
      path_ext = ExecutionEnvironment.user_running_test? ? '' : '/*view*/'
      log_file = ::Cm2Manager.instance.update(:log,scenario.name)
      embed(File.basename(log_file) + path_ext, 'text/plain', 'Scenario Coremetrics YAML') if log_file

      dif_file = ::Cm2Manager.instance.update(:compare,scenario.name)
      embed(File.basename(dif_file) + path_ext, 'text/plain', 'Scenario Coremetrics YAML Diff') if dif_file
      ::Cm2Manager.instance.update(:evaluate,scenario.name)
      ::Cm2Manager.instance.update(:clear,scenario.name)
    rescue StandardError => e
      ::Cm2Manager.instance.update(:clear,scenario.name)
      raise e
    end
  end

  if ExecutionEnvironment.proxy_enabled?('GoogleAnalytics')
    GoogleAnalytics::Recorder.instance.reset
  end

  ENV.each do |env|
    @log.debug "a var: #{env}"
  end

  if !ENV["HEADLESS"].nil?
    @headless.destroy
  end
end

at_exit do
  Database::Connection.close_all
end

# Takes a browser snapshot
# @param file_name [String] optional filename and will default to timestamped file.
# @param embeded_title [String] optional param that will show up as the link text in cucumber report, default is "Screenshot"
# @return [String] the full path to the saved snapshot.
def take_browser_screenshot(file_name="screenshot_#{Time.now.strftime('%Y%m%d-%H%M%S')}.png", embeded_title='Screenshot')
  new_screenshot_path = "#{ExecutionEnvironment.log_directory}/#{file_name}"
  Log.instance.debug "Saving snapshot to \"#{new_screenshot_path}\"..."
  if ENV["HEADLESS"].nil?
    @browser.save_screenshot new_screenshot_path
  else
    @headless.take_screenshot new_screenshot_path
  end
  embed file_name, 'image/png', embeded_title
  new_screenshot_path
end

def cleanup_browser
  Log.instance.debug "Quitting browser instance..."
  @browser.quit unless @browser.nil?
end



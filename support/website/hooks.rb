require 'benchmark'
require 'timeout'
# require_relative 'phantomjs'

# require_all 'support/website/triage/screenshots/desktop'

class Profiler
  @@data = {}
  def self.data
    @@data
  end
end

if ExecutionEnvironment.selenium_grid_hub
  # Only allocate one browser per test session.
  browser = Browser.setup(ExecutionEnvironment.browser_name)
elsif ExecutionEnvironment.host_os == :windows
  # Triage::Screenshots::Desktop::WindowsDesktop.getDesktop
  browser = Browser.setup(ExecutionEnvironment.browser_name)
  # Triage::Screenshots::Desktop::WindowsDesktop.releaseDesktopConnection
  if browser != nil
    browser.quit #terminate since new browser will start at beginning of scenario
  end
end

Before('@bat_refactored_cd') do
  $firefox_debug_test = true
end

Before('@rto_failure') do
  ExecutionEnvironment.enable_rto_failure
end

Before do |scenario, tags|
  @ts = Time.now
  if ExecutionEnvironment.selenium_grid_hub || ExecutionEnvironment.host_os == :windows
    # Only allocate one browser per test session.
    # Triage::Screenshots::Desktop::WindowsDesktop.switchDesktop
    @browser = (ExecutionEnvironment.host_os == :windows)? Browser.setup(ExecutionEnvironment.browser_name):browser
    unless @browser.nil?
      @browser.manage.window.maximize
      Browser.start_proxy
      if ENV['MOBILE_WEB'].nil? && ExecutionEnvironment.browser_name != :safari
        @browser.manage.delete_all_cookies
      end
    end
  else
    # Allocate one browser per test                    z
    @browser = Browser.setup(ExecutionEnvironment.browser_name)
  end
  if ExecutionEnvironment.pros_milan_environment?
    $before_pros_execution ||= (DataServices::ProductService2.set_milan_data('mock'))
  end

  # start IBM Digital Analytics PlugIn Tag Monitor
  ::DaManager.start if ExecutionEnvironment.digital_analytics_enabled?
  if ExecutionEnvironment.proxy_enabled?('CM3')
    @site_step_index ||= 0
    s, title, location = get_scenario_info(scenario)
    s = s[@site_step_index]
    location.gsub!(/^.*\\QAA\\features/,'QAA\features')
    location.gsub!(/:\d+$/,"")
    ExecutionEnvironment.clear_analytic_variable_hash
    ExecutionEnvironment.set_analytics_variable("feature", location)
    ExecutionEnvironment.set_analytics_variable("scenario", title)
    ExecutionEnvironment.set_analytics_variable("step", s.name)
    ExecutionEnvironment.set_analytics_variable("browser", @browser)
    ::Cm3Manager.instance.update(:reset, title)
  end
  File.open(::Triage::TimeoutTriage.recovered_timeouts_log_file, 'a') { |io| }
end

AfterStep do |scenario|
  @site_step_index ||= 0
  step_name = nil
  s, title, location = get_scenario_info(scenario)
  step = s[@site_step_index]
  step_name = step.name

  begin
    @ts_step = @ts if @ts_step.nil?
    t = (Time.now - @ts_step).to_s
    prof = {time: t, step_index: @site_step_index ,browser: ExecutionEnvironment.browser_name, scenario: title, feature: location, step: step.keyword + ' ' + step_name}
    prof = prof.merge({outline: scenario.to_hash}) if scenario.respond_to?(:scenario_outline)
    Profiler.data[CGI.escape(prof.to_json)] = t
    @ts_step = Time.now
  rescue => exception
  end

  if ExecutionEnvironment.proxy_enabled?('CM3')
    # flush step associated tags
    current_url = @browser.current_url rescue nil
    current_url = "" if current_url.nil?
    ExecutionEnvironment.set_analytics_variable("url", current_url)
    ::Cm3Manager.instance.update(:flush_step, step_name)
  end
  @site_step_index += 1

  if ExecutionEnvironment.proxy_enabled?('CM3')
    # set next step info
    step = s[@site_step_index]
    step_name = step.name rescue nil
    ExecutionEnvironment.set_analytics_variable("step", step_name)
  end

  if ExecutionEnvironment.browser_name != :none
    begin
      ErrorHandling.check_for_errors(@browser, false) unless @browser.nil?
    rescue StandardError => e
      @log.error "The following exception occurred when checking for errors on the page: #{e}"
    end

    if ExecutionEnvironment.browser_name == :firefox
      errors = @current_page.execute_script("return window.JSErrorCollector_errors.pump()") rescue []
      if errors.any?
        @log.error '-------------------------------------------------------------'
        @log.error "Found #{errors.length} javascript error(s)"
        errors.each do |error|
          @log.error " #{error["errorMessage"]} (#{error["sourceName"]}:#{error["lineNumber"]})"
        end
        @log.error '-------------------------------------------------------------'
        #raise "Javascript #{errors.length} error(s) detected, see above"
      end
    end

    # Write out a warning message if the site we're testing is an fds.com environment, but the page
    # we ended up on is macys.com or bloomingdales.com
    current_url = @browser.current_url rescue nil
    unless current_url.nil? || /(usps|milan)/.match(current_url) || ExecutionEnvironment.acceptable_site_transition?(current_url)
      raise "ERROR - ENV: The starting environment domain '#{ExecutionEnvironment.url}' does not match the current page's domain '#{current_url}'"
    end
  end
end

# Important - the After step should not throw any errors.  Verify the @browser instance is not nil
# before using it, catch any errors thrown from taking screenshots, etc.
After do |scenario|
  begin
    @step_index = nil
    t = Time.now - @ts
    s, title, location = get_scenario_info(scenario)
    iFailed = -1
    s.each_with_index{|v,i| iFailed = i if v.status == :failed}

    tsPassSteps = 0.0;
    ENV.select {|k,v|
      isScenario = k.include?('"scenario":"' + title + '"')
      if scenario.respond_to?(:scenario_outline)
        isScenario = isScenario && k.include?(scenario.to_hash.to_json)
      end
      isScenario
    }.map {|k,v| JSON.parse(k)}.each {|s| tsPassSteps += s['time'].to_f}
    if (iFailed > -1)
      prof = {time: (t-tsPassSteps).to_s, browser: ExecutionEnvironment.browser_name, status: scenario.status, scenario: title, feature: location, step: s[iFailed].keyword + ' ' + s[iFailed].name}
      prof = prof.merge({outline: scenario.to_hash}) if scenario.respond_to?(:scenario_outline)
      Profiler.data[CGI.escape(prof.to_json)] = prof[:time]
    end
    prof = {time: t.to_s, browser: ExecutionEnvironment.browser_name, status: scenario.status, scenario: title, feature: location}
    Profiler.data[CGI.escape(prof.to_json)] = prof[:time]
  rescue => exception
  end
  @log.error "Exception: #{scenario.exception}\n" + scenario.exception.backtrace.join("\n") if scenario.failed?
  @logged_failure_exception = true

  if ExecutionEnvironment.proxy_enabled?('CM3')
    ::Cm3Manager.instance.update(:log, scenario_name)
  end

  begin
    begin
      ErrorHandling.check_for_errors(@browser, false) unless @browser.nil?
    rescue StandardError => e
      @log.error "The following exception occurred when checking for errors on the page: #{e}"
    end

    if scenario.failed?
      triager = Triage::TimeoutTriage.new(@browser)
      if scenario.exception.message.include? "execution expired"
        triager.log_cpu_load
        #triager.log_document_state
      end

      begin
        screenshotter = Triage::Screenshots::Desktop::Factory.screenshot_taker(Log.instance.timestamp)
        screenshotter.take_screenshot
        embed(File.basename(screenshotter.screenshot_path), 'image/jpg', 'Desktop') rescue false
      rescue StandardError => e
        @log.error "Unable to take desktop screenshot: #{e.message} #{e.backtrace.join("\n")}"
      end
    end

    # Embed Proxy HAR logging file path in Cucumber Log
    if ExecutionEnvironment.proxy_enabled?('LOGGING')
      path_ext = ExecutionEnvironment.user_running_test? ? '' : '/*view*/'
      embed(File.basename(Proxy.get_har_file_path) + path_ext, 'text/plain', 'Proxy HAR File')
    end

    # close IBM Digital Analytics PlugIn Tag Monitor
    ::DaManager.close if ExecutionEnvironment.digital_analytics_enabled?


    @browser.manage.delete_all_cookies unless @browser.nil? rescue nil
  end

  # Even though running and debugging tests from RubyMine on Digital Analytics, required to close the browser window.
  # Otherwise, the next scenario would be failed
  if ExecutionEnvironment.digital_analytics_enabled?('plugin') || ExecutionEnvironment.close_browser_redmine?
    unless @browser.nil?
      @log.debug "Closing browser."
      Browser.quit_browser
    end
  end
end



  # When running and debugging tests from RubyMine, don't close the browser window.
  # This helps with debugging to leave it open.
  unless @browser.nil?
    if !ExecutionEnvironment.user_running_test? && ExecutionEnvironment.selenium_grid_hub.nil? #&& ExecutionEnvironment.host_os != :windows
      @log.debug "Closing browser."
      Browser.quit_browser
    else
      Browser.close_proxy
    end
end

at_exit do
  prof = Profiler.data.select {|k, v| CGI.unescape(k).include?('"scenario":')}
  if (prof.length > 0)
    profsort = prof.sort {|a1,a2| a2[1].to_i<=>a1[1].to_i} if prof.length > 1
    p "-----"
    p profsort
    totalTime = 0
    profsort.each { |k, v|
      totalTime += v.to_f
    }
    begin
      file = File.open("log/scenario_profile.log", "a")
      file.write(prof.map {|k, v| CGI.unescape(k)}.join("\n"))
      file.write("\n\n\n")
    rescue IOError => e
      #some error occur, dir not writable etc.
    ensure
      file.close unless file == nil
    end
  else
    ENV.each {|k, v| puts k + '=' + v}
  end

  Triage::Screenshots::Desktop::WindowsDesktop.releaseDesktop
end

def get_scenario_info(scenario)
  return scenario.steps.to_a, scenario.title, scenario.location.to_s if scenario.respond_to?(:steps)
  return scenario.instance_variable_get("@step_invocations").to_a, scenario.scenario_outline.title, scenario.scenario_outline.location.to_s
end

def take_browser_screenshot_with_exception(exception = nil, error_msg = '')
  unless error_msg.empty?
    error_msg = error_msg + (exception.nil? ? ' ' : ' and Exception: ')
  end
  error = exception.nil? ? (error_msg + 'Screenshot') : (error_msg + exception.to_s + '<br>' + exception.backtrace[0..4].join('<br>') + '<br>')

  #The error screenshot count is here for tests that support capturing multiple errors and exceptions.
  #The error count is unique for each scenario.
  @error_screenshot_counter = 0 if @error_screenshot_counter.nil?
  @error_screenshot_counter += 1
  timestamp = Time.now.strftime('%Y_%m_%d-%HH_%MM_%SS_%LS')
  take_browser_screenshot("screenshot_#{timestamp}.png", "Error #{@error_screenshot_counter.to_s} - " + error)
end

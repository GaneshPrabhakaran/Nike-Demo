require 'timeout'

module Browser
  # require_relative 'proxy'
  # require_relative 'phantomjs'

  #
  # Closes browser at the end of test.
  #
  def self.close_browser
    close_proxy
    @browser.close
    sleep 5
  end

  #
  # Quits browser at the end of test without closing the window.
  #
  def self.quit_browser
    close_proxy
    @browser.quit
    sleep 5
  end

  def self.is_first_visit_to_site?
    is_current_url_a_site_url? ? @is_first_visit_to_site : false
  end

  def self.is_current_url_a_site_url?
    #Current hostname == Site hostname
    ExecutionEnvironment.environment_name(@browser.current_url) == ExecutionEnvironment.host_name.split(/\./)[1]
  end

  def self.visited_site
    @is_first_visit_to_site = false
  end

  #
  # Restarts the browser in the middle of a test.  The default is to not clear the browser's cookies.
  #
  def self.restart_browser(browser = ExecutionEnvironment.browser_name, clear_cookies = false, disable_cookies = false)
    BrowserHelper.close_popup(@browser)
    close_browser
    original_disable_cookies = @disable_cookies
    begin
      @disable_cookies = disable_cookies
      @browser = setup(browser, clear_cookies)
    ensure
      @disable_cookies = original_disable_cookies
    end
  end

  def self.close_proxy
    if ExecutionEnvironment.proxy_enabled? and @proxy_started
      ::CoreMetricsManager.instance.update_har_entries if ExecutionEnvironment.proxy_enabled?('CoreMetrics')
      @proxy_started = nil
      Proxy.close_proxy
    end
  end

  def self.start_proxy
    if ExecutionEnvironment.proxy_enabled? and !@proxy_started
      @proxy_started = Proxy::start_proxy.selenium_proxy(:http, :ssl)
    end
    @proxy_started
  end

  def self.proxy
    ExecutionEnvironment.proxy_enabled? ? start_proxy : false
  end

  #
  # Sets up a browser instance, enabling any necessary browser capabilities.
  # @param [Symbol] browser One of: :firefox, :chrome, :ie
  #
  def self.setup(browser = ExecutionEnvironment.browser_name, clear_cookies = true)
    p ExecutionEnvironment.browser_name
    @is_first_visit_to_site = true
    if ENV['MOBILE_WEB']
      @browser = setup_mobile
      @browser
    elsif browser == :none
      nil
    else
      if ExecutionEnvironment.digital_analytics_enabled?('plugin')
        if ExecutionEnvironment.host_os != :windows || ExecutionEnvironment.browser_name != :firefox
          raise("ERROR - ENV: Digital Analytics runs only on Windows and Firefox")
        end
      end
      begin
        if ExecutionEnvironment.reuse_browser?
          @browser_count ||= 0
          # reuse the browser from the second one. The first one will be close shortly and never used
          if @browser_count < 2
            @browser = self.send "setup_#{browser.to_s}"
            maximize_browser_window
            @browser_count += 1
          end
        else
          @browser = self.send "setup_#{browser.to_s}"
          maximize_browser_window
        end
        @browser.manage.delete_all_cookies if clear_cookies unless ExecutionEnvironment.browser_name == :safari || :ie
        @browser
      rescue Timeout::Error
        raise $!, "Unable to acquire a(n) '#{browser.to_s}' browser session from the hub." if ExecutionEnvironment.selenium_grid_hub
        raise
      end
    end
  end


  class << self
    private

    def common_capabilities
      caps = {}
      caps[:platform] = ExecutionEnvironment.browser_os if ExecutionEnvironment.browser_os
      caps[:version] = ExecutionEnvironment.browser_version if ExecutionEnvironment.browser_version
      caps
    end

    def setup_firefox
      if ExecutionEnvironment.selenium_grid_hub.nil?
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile.log_file = browser_log_file_path("firefox")
        profile['network.cookie.cookieBehavior'] = 2 if @disable_cookies

        if ExecutionEnvironment::Features.noscript?
          untrusted = %w(bazaarvoice.com)
          profile.add_extension("vendor/firefox_extensions/noscript.xpi")
          profile["noscript.ABE.migration"] = 1
          profile["noscript.global"] = true
          profile["noscript.gtemp"] = ""
          profile["noscript.temp"] = ""
          profile["noscript.untrusted"] = untrusted.map { |domain| [domain, "http://#{domain}", "https://#{domain}"] }.flatten.join(' ')
          profile["noscript.version"] = "2.6.8.19"
          profile["noscript.visibleUIChecked"] = true
          Log.instance.debug "Running with 'noscript' plugin.  Untrusted domains: #{untrusted}"
        end

        if ExecutionEnvironment::Features.akamai?
          profile.add_extension('vendor/firefox_extensions/modify_headers-0.7.1.1-fx.xpi', 'modifyheaders')
          profile.add_extension('vendor/firefox_extensions/firebug-2.0.4-fx.xpi', 'firebug')
          profile.add_extension('vendor/firefox_extensions/netExport-0.9b6.xpi', 'netexport')

          profile['modifyheaders.config.active'] = true
          profile['modifyheaders.config.alwaysOn'] = true
          profile['modifyheaders.config.openNewTab'] = true
          profile['modifyheaders.start'] = true

          headers = 'akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-check-cacheable, akamai-x-get-cache-key, akamai-x-get-extracted-values, akamai-x-get-nonces, akamai-x-get-ssl-client-session-id, akamai-x-get-true-cache-key, akamai-x-serial-no, akamai-x-cache-remote-on'
          profile['modifyheaders.headers.count'] = 1
          profile['modifyheaders.headers.action0'] = 'Add'
          profile['modifyheaders.headers.name0'] = 'Pragma'
          profile['modifyheaders.headers.value0'] = headers
          profile['modifyheaders.headers.enabled0'] = true

          profile['extensions.firebug.currentVersion'] = '2.0.4'
          profile['extensions.firebug.addonBarOpened'] = true
          profile['extensions.firebug.console.enableSites'] = true
          profile['extensions.firebug.script.enableSites'] = true
          profile['extensions.firebug.net.enableSites'] = true
          profile['extensions.firebug.previousPlacement'] = 1
          profile['extensions.firebug.allPagesActivation'] = 'on'
          profile['extensions.firebug.onByDefault'] = true
          profile['extensions.firebug.defaultPanelName'] = 'net'

          profile['extensions.firebug.netexport.alwaysEnableAutoExport'] = true
          profile['extensions.firebug.netexport.autoExportToFile'] = true
          profile['extensions.firebug.netexport.Automation'] = true
          profile['extensions.firebug.netexport.showPreview'] = false
          profile['extensions.firebug.netexport.includeResponseBodies'] = false
          profile['extensions.firebug.netexport.secretToken'] = 'macys'
          if ExecutionEnvironment.host_os == :windows
            profile['extensions.firebug.netexport.defaultLogDir'] = ExecutionEnvironment.log_directory.gsub('/','\\')
          else
            profile['extensions.firebug.netexport.defaultLogDir'] = ExecutionEnvironment.log_directory
          end
        end

        profile.proxy = start_proxy if ExecutionEnvironment.proxy_enabled?

        profile.add_extension('vendor/firefox_extensions/JSErrorCollector.xpi')

        if ExecutionEnvironment.digital_analytics_enabled?('plugin')
          profile.add_extension("vendor/firefox_extensions/coremetricstools@coremetrics.xpi")
        end

        Selenium::WebDriver.for :firefox, :profile => profile
      else
        caps = Selenium::WebDriver::Remote::Capabilities.firefox(common_capabilities)
        Selenium::WebDriver.for(:remote, :url => ExecutionEnvironment.selenium_grid_hub, :desired_capabilities => caps)
      end
    end

    def setup_chrome
      unless ExecutionEnvironment.selenium_grid_hub.nil?
        caps = Selenium::WebDriver::Remote::Capabilities.chrome(common_capabilities)
        return Selenium::WebDriver.for :remote, :url => ExecutionEnvironment.selenium_grid_hub, :desired_capabilities => caps
      end
      if ExecutionEnvironment::Features.akamai?
        extensions = "--load-extension=#{Dir.getwd}/vendor/chrome_extensions/HTTP_Spy/,#{Dir.getwd}/vendor/chrome_extensions/Modify_Headers/"
        return Selenium::WebDriver.for :chrome, :switches => [extensions], :proxy => proxy
      end
      caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => ["test-type", "--disable-extensions", "--kiosk-printing"]})
      Selenium::WebDriver.for :chrome, desired_capabilities: caps, proxy: proxy
    end

    def setup_ie
      opts = { :'ie.ensureCleanSession' => true, :enablePersistentHover => false, :nativeEvents => false }
      if ExecutionEnvironment.selenium_grid_hub.nil?
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer(opts)
        Selenium::WebDriver.for :ie, :desired_capabilities => caps, :native_events => false
      else
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer(opts.merge(common_capabilities))
        Selenium::WebDriver.for(:remote, :url => ExecutionEnvironment.selenium_grid_hub, :desired_capabilities => caps)
      end
      # This is breaking IE execution because the Selenium browser instance isn't returned.
      # In addition, the profile variable doesn't exist.
      #
      # if ExecutionEnvironment.proxy_enabled?
      #   profile.proxy = Proxy::start_proxy.selenium_proxy(:http, :ssl) #proxy.selenium_proxy
      # end
    end

    def setup_phantomjs
      PhantomJS.instance.start_js_server
      Selenium::WebDriver.for(:phantomjs, url: 'http://localhost:' + ENV["PHANTOMJS_PORT"])
    end

    def setup_safari
      safari_user=File.expand_path('~')
      safari_path="#{safari_user}/Library/Safari"
      #FileUtils.rm_rf Dir.glob("#{safari_path}/*")
      dirs = Dir.entries("#{safari_path}").reject { |f| f =~ /Extensions|.DS_Store/ }
      dirs.each do |dir|
        unless dir.to_s == "." || dir.to_s == ".."
          FileUtils.rm_rf File.join("#{safari_path}", dir)
        end
      end
      file_location = File.expand_path File.dirname(__FILE__)
      cmd = "osascript #{file_location}/safaricookie_applescript.scpt"
      system cmd
      browser=Selenium::WebDriver.for :safari
      browser
    end

    def browser_log_file_path(browser_name)
      # The log file name must be an absolute path, and the slashes must be correct for either Windows or Linux.
      # Use the cucumber log's timestamp in the browser log file name.
      log_file = "#{ExecutionEnvironment.log_directory}/#{browser_name}_#{Log.instance.timestamp}.log"
      log_file.gsub!('/', '\\') if ExecutionEnvironment.host_os == :windows
      log_file
    end

    #Selenium maximize window is broken on OSX for chrome and it works for other browsers
    def maximize_browser_window
      if ExecutionEnvironment.host_os == :macosx
        position = @browser.manage.window.position
        if position.x + position.y > 0
          position.x = 0
          position.y = 0
          @browser.manage.window.position = position
        end
        max_width, max_height = @browser.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
        @browser.manage.window.resize_to(max_width, max_height)
      else
        @browser.manage.window.maximize
      end
    end
  end
end

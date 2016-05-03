class MobileDevice
  class Base
    def perform
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = 300

      Selenium::WebDriver.for :remote, url: url, desired_capabilities: desired_capabilities, http_client: client
    end

    # CALLBACKS
    def initialize
      open # THIS SHOULD BE RAN ONLY ONCE
    end

    def open
      setup
      @browser = perform
    end

    def close
      close_proxy
      browser.quit if browser.present?

      teardown
    end

    def setup
      nil
    end

    def teardown
      nil
    end

    def close_proxy
      if ExecutionEnvironment.proxy_enabled? && @proxy_started
        ::CoreMetricsManager.instance.update_har_entries if ExecutionEnvironment.proxy_enabled?('CoreMetrics')
        @proxy_started = nil
        Proxy.close_proxy
      end
    end

    def start_proxy
      if ExecutionEnvironment.proxy_enabled? && !@proxy_started
        @proxy_started = Proxy.start_proxy.selenium_proxy(:http, :ssl)
      end
      @proxy_started
    end

    def proxy
      ExecutionEnvironment.proxy_enabled? ? start_proxy : false
    end

    attr_reader :browser

    def reset_cookies?
      return false if @reset_cookies == 'yes'
      @reset_cookies = 'yes'
      true
    end
  end
end

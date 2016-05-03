require 'benchmark'
require 'httparty'
require 'uri'
require 'socket'

module ExecutionEnvironment
  extend self

  def config
    @config ||= YAML::load_file('config/framework.yml')
  end

  #
  # Returns true if a user is running the cucumber or rspec test.  This may be useful for debugging purposes.
  #
  def user_running_test?
    return true if ENV['CUCUMBER_FORMAT'] == 'Teamcity::Cucumber::Formatter'
    return true if ENV['TEAMCITY_RAKE_RUNNER_MODE'] == 'idea'
    return true if ENV['RAKE_CONSOLE'] == 'true'
    false
  end

  M_BCOM_VALID_URL = /(?<scheme>(https?)?)\:\/+(?<subdomain>(www|mdev1|m2qa1|origin\d?\-m|m{1})?)\.?(?<host>(.*?\.com|localhost)?)\:?(?<port>(\d+)?)/

  # Returns the host but without the prefix
  # @return Example: qa20codemacys.fds.com  (no m. or m2qa1. prefixes)
  def host
    M_BCOM_VALID_URL.match(url)[:host]
  end

  #
  # The base URL the test session is testing against.
  #
  def url
    raise "The 'URL' environment variable was not specified on the cucumber command line." if ENV['URL'].nil?
    ENV['URL']
  end

  def experiments
    ENV['EXPERIMENTS']
  end

  def host_name
    URI(self.url).host
  end

  def nav_app
    nav_app = (ENV['NAV_APP'].nil?) ? false : ENV['NAV_APP']
  end

  #Parameter for Parasoft host, use: MOCK_HOST=esu2v872. Default: esu2v871
  def mock_host
    mock_host = (ENV['MOCK_HOST'].nil?) ? 'esu2v871' : ENV['MOCK_HOST']
  end

  # Returns the environment details service host:port. By default we use a Parasoft host
  # with a cached version of the environment details from the REAPPS API endpoint.
  def myservices_environment_details_host
    ENV['ENV_DETAILS'].nil? ? 'esu2v871:9080' : ENV['ENV_DETAILS']
  end

  # If the ENV_DETAILS environment variable exists, then we are overriding the default endpoint for
  # the environment details service.
  def myservices_environment_details_override?
    !ENV['ENV_DETAILS'].nil?
  end

  #
  # Returns true if a url is in the same environment as the starting environment, or if we have transitioned
  # to an acceptable third party site.  This prevents us from crossing internal environments, or moving to
  # production from a development environment.
  #
  def acceptable_site_transition?(current_url)
    return false if current_url.nil?
    return true if current_url.include?("/cms/deals/BACK_TO_SCHOOL")
    return true if current_url == "about:blank"
    return true if current_url == "data\:\,"
    return true if current_url.include?(ExecutionEnvironment.url.sub(/www1?/, 'www1.pos')) # SNS URL
    return true if current_url == "http://mdc2vr4073:9099/RAPADDashboardConfig/stage5TrunkDeploy.html"
    return true if current_url.include?("secure-m") || current_url.include?("localhost") #mobile regression secure-m transitions
    return true if google_cloud_match(current_url)

    accepted_external_sites = %w(
      macys--tst.custhelp.com
      m.macys.com
      customerservice.macys.com
      macysinc.com
      social.macys.com
      macys.circularhub.com
      m.qa20codemacys.fds.com
      m2qa1.qa10codebloomingdales.fds.com
      prefcenter.email.macys.com
      slimages.macysassets.com
      stores.macysbackstage.com

      customerservice.bloomingdales.com
      bloomingdales--upgrade.custhelp.com
      bloomingdalesjobs.com
      www.bloomingdalesjobs.com
      bloomingdales--tst.custhelp.com
      bloomingdales--dev.custhelp.com
      fashion.bloomingdales.com
      fashion-staging.bloomingdales.com

      citibank.com
      facebook.com
      m.facebook.com
      www.facebook.com
      twitter.com
      mobile.twitter.com
      instagram.com
      pinterest.com
      mailinator.com
      www.pinterest.com
      play.google.com
      young-retreat-5909.herokuapp.com
      e1et-www.plenti.com
      www.sandbox.paypal.com

      sit02.accountonline.com
      test02.accountonline.com
      sit04.accountonline.com
      test04.accountonline.com
      test01.accountonline.com
      uat03.accountonline.com
      uat04.accountonline.com
      uat04.mobile.citibank.com
      uat03.mobile.citibank.com
      www.plenti.com
    )
    current_host  = URI.parse(URI.encode(current_url.gsub(/[\[\]]/,''))).host
    starting_host = URI.parse(URI.encode(self.url.strip)).host
    return true if accepted_external_sites.include? current_host

    current_host.split(/\./)[1] == starting_host.split(/\./)[1]
  end

  def google_cloud_match(url=nil)
    starting_host = URI.parse(URI.encode(self.url.strip)).host
    current_host = URI.parse(URI.encode(url.gsub(/[\[\]]/,''))).host
    return false if current_host.split(/\./)[0] != starting_host.split(/\./)[0]
    return false if current_host.match(/([^\.]+)\.c4d\.devops\.fds\.com/) && !(starting_host.match(/([^\.]+)\.gce\.c4d\.griddynamics\.net/))
    return false if starting_host.match(/([^\.]+)\.c4d\.devops\.fds\.com/) && !(current_host.match(/([^\.]+)\.gce\.c4d\.griddynamics\.net/))
    true
  end

  #
  # Returns true if the site under test is a development environment (fds.com).
  #
  def development_environment?(url = nil)
    url ||= self.url
    !production_environment?(url)
  end

  #
  # Returns true if the site under test is a production environment (macys.com, bloomingdales.com).
  #
  def production_environment?(url = nil)
    url ||= self.url
    !!url.match(/(macys|bloomingdales)\.com/)
  end

  #
  # Returns true if the site under test is a GoGrid environment instead of a MyServices environment.
  #
  def gogrid_environment?(url = nil)
    url ||= self.url
    !!url.match(/cistages\.fds/)
  end

  #
  # Returns true if the site under test is a Google Cloud environment instead of a GoGrid environment.
  #
  def google_cloud_environment?(url = nil)
    url ||= self.url
    !!url.match(/\.c4d\.devops\.fds\.com/) || !!url.match(/\.gce\.c4d\.griddynamics\.net/)
  end

  #
  # Returns the environment type for the given URL: either :gogrid or :myservices
  #
  def environment_type(url = nil)
    if gogrid_environment?(url)
      :gogrid
    elsif google_cloud_environment?(url)
      :google
    else
      :myservices
    end
  end

  #
  # Returns true if the current environment is pointing to one or more mocked services.  An example is if
  # the PrepareOrder endpoint in SDP is pointed to the mock server instead of D2C.
  #
  def mock_environment?
    # The GoGrid environments have a mockedServices: true/false value in the environment details.  This is a much
    # easier way to determine if the environment uses mocked services.  The RE team is updating the MyServices
    # environment details service to also have this value.  This mock_environment? method handles both cases until
    # the RE teams' service is updated.
    details = EnvironmentDetails.environment_details
    if details.has_key?('mockedServices')
      Log.instance.debug "Mocked environment? : #{details['mockedServices']}"
      return details['mockedServices']
    end

    #
    # The old school way of going to SDP to determine if we're a mocked environment...
    #
    endpoint = EnvironmentDetails.apps.sdp.environment_property('store.service.getstoreavailability.endpoint')
    # The endpoint may have some characters 'escaped', like: http\://lmia0123/path/to/endpoint
    endpoint.gsub!('\\', '')
    host = URI(endpoint).host

    @mock_environment ||= {}
    return @mock_environment[host] if @mock_environment.has_key? host

    # The mock servers have a ping service we can test for existence.
    endpoint = "http://#{host}/IsThisAMock/pingservice.asp"
    Log.instance.debug "Checking if we are a mock environment: #{endpoint}"
    response = HTTParty.post(endpoint, :body => "")
    @mock_environment[host] = response.code == 200
    Log.instance.debug "Mocked environment? [#{host}] : #{@mock_environment[host]}"
    @mock_environment[host]
  rescue => e
    # TODO Need an approach for partial environment names "http://mcomtest002.qa10.c4d.griddynamics.net/"
    # TODO or IP addresses used as URL.
    Log.instance.warn "Error looking up environment property: #{e}"
    Log.instance.warn "Mocked environment? [#{host}] : false"
    false
  end

  def mobile?
    ENV['MOBILE']
  end

  #
  # Returns true if the current environment is pointing to calabash
  #
  def calabash?
    ENV['CALABASH'] == nil ? false : true
  end

  #
  # Returns true if the current environment is wanting to use a dockerized database client
  # instead of the mac os installed ones.
  # Is used by ios app in conjunctions with our data helper to use dockerized ibm and oracle gems
  #
  def ios_dockerized_database_clients?
    # use the installed environment variable required to make ibm gems work on mac to determine whether
    # to use the dockerized version or not.
    ENV['IBM_DB_HOME'].nil?
  end

  def mobile_website?
    (ENV['MOBILE_WEB'].nil? ? false : ENV['MOBILE_WEB'].upcase == 'TRUE') || (!ENV['PROJECT'].nil? && ENV['PROJECT'].upcase == 'MOBILE_WEBSITE')
  end

  def mew_mock?
    url ||= self.url
    uri = URI(url)
    (uri.host) == 'localhost'
  end


  def tablet?
    ENV['TABLET'] == 'true'
  end

  def pros_milan_environment?
    ENV['MILAN'] == 'true'
  end

  #
  # Returns the environment name for a given URL.
  # Parses: www.qa20codemacys.fds.com
  #         www1.pos.qa20codemacys.fds.com
  #         origin-www.qa20codemacys.fds.com
  # GoGrid environment name: http://mcomtest002.qa10.c4d.griddynamics.net/
  # Mobile: m2qa1.qa6codebloomingdales.fds.com
  #         m.macys.com
  #
  def environment_name(url = nil)
    url ||= self.url
    uri = URI(url)

    if (uri.host == 'localhost')
      if uri.port.nil?
        uri.host;
      else
        "#{uri.host}:#{uri.port}"
      end
    else
      name = case uri.host
               when /(?:origin-)?www\d?(?:\.pos)?(?:\.siteb)?\.([^\.]+)(?:\.fds)?\.com/,
                   /(?:m|m2qa1|mdev1|mockmacys|local)\.([^\.]+)(?:\.fds)?\.com/, # mobile env
                   /([^\.]+)\.\w+\.\w+\.griddynamics\.net/, # partial env
                   /([^\.]+)\.stage2\.cistages\.fds/, # stage 2 env
                   /([^\-]+)-staging.bloomingdales\.com/, #BCOM Heroku Staging Env
                   /([^\.]+).bloomingdales\.com/, #BCOM Heroku Production Env
                   /([^\.]+)\.cistages\.fds/,
                   /([^\.]+)\.macysbackstage\.com/,
                   /([^\.]+)\.herokuapp\.com/,
                   /([^\.]+)\.c4d\.devops\.fds\.com/,
                   /sstportal/
                 Regexp.last_match.captures.first
               else
                 raise URI::InvalidURIError, "URI was not recognized: '#{url}'."
             end
      name
    end
  end

  def log_directory
    @log_directory ||= "#{Dir.getwd}/log"
  end

  #
  # Returns true if the current environment is the MEW site; false otherwise.
  #
  def rc_mew_flow?
    ENV['RCFLOW'] == nil ? false : true
  end
  #
  # Returns true if the current environment is the Macys site; false otherwise.
  #
  def macys?(url = nil)

    if mobile? or (ENV['SITE'])
      ENV['SITE'].upcase == 'MCOM'
    else
      url ||= self.url
      environment_name(url).match(/mcom|macys|mockmacys/i) ? true : false

    end
  end

  #
  # Returns true if the current environment is the Macys site; false otherwise.
  #
  def bloomingdales?(url = nil)
    not macys?(url)
  end

  #
  # Returns the operating system the test host is running on.
  # @return [Symbol] One of: :windows, :macosx, :linux, :unix
  #
  def host_os
    @os ||= (
    case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise "Unknown os: #{RbConfig::CONFIG['host_os']}"
    end
    )
  end

  # Returns the IP Address the test is running on.  This is useful for tracking issues with VMs.
  def host_address
    @address ||= (
    begin
      # turn off reverse DNS resolution temporarily
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

      # A connection is not actually attempted to the external address.
      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    rescue => error
      @log.warn "Unable to determine host address: #{error}"
    ensure
      Socket.do_not_reverse_lookup = orig
    end
    )
  end

  # The browser to run tests against.  One of :firefox, :chrome, :ie, or :safari.
  def browser_name
    env_browser = ENV['BROWSER'] || ENV['BROWSERNAME'] || ENV['BROWSER_NAME'] || ENV['DEVICE']
    env_browser.nil_or_empty? ? config['default_browser'].to_sym : env_browser.downcase.to_sym
  end

  # The specific browser version to run against.
  def browser_version
    ENV['BROWSER_VERSION']
  end

  # The target OS to run tests against.  This requires the selenium grid hub to be set.
  # Valid command line values are windows, mac, linux
  # @return [Symbol] One of: nil, :windows, :mac, :linux
  def browser_os
    if ENV['BROWSER_OS']
      raise "You must also specify the variable GRID_HUB on the command line to use this option." if selenium_grid_hub.nil?
      raise "Unrecognized BROWSER_OS value: #{ENV['BROWSER_OS']}." unless ENV['BROWSER_OS'] =~ /^windows|mac|linux$/i
      ENV['BROWSER_OS'].downcase.to_sym
    else
      nil
    end
  end

  # Returns the test execution timeout.  The default is 10 minutes, and can be overridden on the cucumber
  # command line with TEST_TIMEOUT=15
  def test_timeout_minutes
    ENV['TEST_TIMEOUT'].to_f || config['default_test_timeout_minutes']
  end

  # The hub address (like http://localhost:4444/wd/hub) to point the test to.  Default is nil (run tests against local browsers).
  def selenium_grid_hub
    ENV['GRID_HUB']
  end

  # Returns whether the execution is running on Appurify.

  def is_appurify?
    ENV['APPURIFY_EXECUTION'] == 'true'
  end

  # Returns if proxy is enabled. Also checks if other env variables should enable the proxy during execution

  def proxy_enabled?(spec=nil)
    ENV['PROXY'] ||= 'CM4' if (ENV['DIGITAL_ANALYTICS'] && ENV['DIGITAL_ANALYTICS'].include?('proxy') || ENV['RTO_FAILURE'] && ENV['RTO_FAILURE'].upcase == 'TRUE')
    if ENV['PROXY'].nil? || ENV['PROXY'].upcase == 'FALSE'
      false
    elsif spec.nil?
      true
    else
      ENV['PROXY'].include?(spec)
    end
  end

  def ios_proxy_enabled?
    if ENV["IOS_PROXY"].nil?
      false
    else
      true
    end
  end

  def proxy_path
    if ENV['PROXY_PATH']
      ENV['PROXY_PATH']
    else
      case ExecutionEnvironment.host_os
        when :linux, :macosx then "/opt/browsermob/bin/browsermob-proxy"
        when :windows        then "c:\\browsermob-proxy\\bin\\browsermob-proxy.bat"
        else                 raise "Unsupported host OS: #{ExecutionEnvironment.host_os}"
      end
    end
  end

  # CM3
  def clear_analytic_variable_hash
    @analytics_var_hash = {}
  end


  # DIGITAL_ANALYTICS
  #   available arguments
  #      plugin
  #      proxy
  def digital_analytics_enabled?(spec=nil)
    if ENV['DIGITAL_ANALYTICS'].nil? || ENV['DIGITAL_ANALYTICS'].upcase == 'FALSE'
      false
    elsif spec.nil?
      true
    else
      ENV['DIGITAL_ANALYTICS'].include?(spec)
    end
  end

  def get_analytic_variable_hash
    @analytics_var_hash
  end

  def set_analytics_variable(name, value)
    @analytics_var_hash ||= {}
    @analytics_var_hash[name] = value
  end

  def get_analytics_variable(name)
    @analytics_var_hash ||= {}
    @analytics_var_hash[name]
  end

  # ignore Digital Analytics Error and Continue the test execution flag
  def ignore_digital_execution_error?
    ENV['IGNORE_DA_ERROR']
  end

  # ignore Digital Analytics Error and Continue the test execution flag
  def no_da_test?
    ENV['NO_DA_TEST']
  end

  # when run many scenarios in one feature file, it is better to close browser each scenario
  def close_browser_redmine?
    ENV['CLOSE_BROWSER']
  end

  #
  # If the MISCGCs cookie is present, the cookie is deleted and the browser is reloaded with a different URL.
  # The domain name is prepended with origin- to bypass akamai.  This is needed for test scenarios (BOPS in particular).
  #
  def bypass_akamai(browser, urlparameter='', pageurl='')


    case urlparameter
      when ''
        reload_url = false
        cookies = browser.manage.all_cookies
        cookies.each do |cookie|
          if cookie[:name] == 'MISCGCs'
            browser.manage.delete_cookie('MISCGCs')
            reload_url = true
          end
        end
        current_url = browser.current_url
        if !(current_url.include?'origin')
          if current_url.include?'https'
            current_url = "https://origin-#{current_url[8, current_url.length]}"
          else
            current_url = "http://origin-#{current_url[7, current_url.length]}"
          end
        end
        browser.navigate.to(current_url) if reload_url
      else
        cookies = browser.manage.all_cookies
        cookies.each do |cookie|
          if cookie[:name] == 'MISCGCs'
            browser.manage.delete_cookie('MISCGCs')
          end
        end

        tableturl =  ExecutionEnvironment.url.dup
        current_url = tableturl.insert(7,'origin-') + pageurl + urlparameter
        Log.instance.debug "current_url is #{current_url}"
        browser.navigate.to(current_url)
    end
  end

  def fake_akamai(browser, urlparameter='', pageurl='')
    cookies = browser.manage.all_cookies
    cookies.each do |cookie|
      if cookie[:name] == 'MISCGCs'
        browser.manage.delete_cookie('MISCGCs')
      end
    end

    tableturl =  ExecutionEnvironment.url.dup
    current_url = tableturl + pageurl + urlparameter
    Log.instance.debug "current_url is #{current_url}"
    browser.navigate.to(current_url)
  end

  def deep_link_url
    ENV['AD_URL']
  end

  # Environment variable to force rto calls to be dropped by proxy

  def enable_rto_failure
    ENV['RTO_FAILURE'] ||= 'true'
  end

  def force_rto_failure?
    rto_failure = ENV['RTO_FAILURE']
    if rto_failure.nil?
      false
    else
      rto_failure.upcase == 'TRUE' ? true : false
    end
  end

  def deep_link_category
    if ENV['CAT_AD'].nil?
      raise StandardError, "ENV['CAT_AD'] Returning null value.."
    else
      ENV['CAT_AD'].downcase
    end
  end

  # Environment variable to enable reuse the same browser for multiple scenario only on website.
  def reuse_browser?
    return true if ENV['REUSE_BROWSER'] == 'true'
  end

  # site release version
  def site_release
    ENV['RELEASE_VERSION']
  end

  # Flag indicating whether the SQL query should randomize the returned data.
  # Default is FALSE. TRUE means do not randomize. When the flag is TRUE, the SQL query will query
  # for a specific product ID based on the product attributes. For a given set of attributes,
  # the product ID is extracted from the YML file.
  def no_randomization
    ENV['NO_RANDOM'].nil? ? false : ENV['NO_RANDOM'].upcase == 'TRUE'
  end

  #
  # Feature flags indicating whether a new feature is enabled/disabled in the environment.  These flags should be
  # deleted as soon as the new feature development becomes standard.
  #
  module Features
    def self.my_wallet_redesign?
      redesign = ENV['MY_WALLET_REDESIGN']
      redesign.nil_or_empty? ? false : true
    end

    def self.international_context_new?
      iship_redesign = ENV['INTERNATIONAL_CONTEXT_NEW']
      iship_redesign.nil_or_empty? ? false : true
    end

    def self.gift_card_balance_redesign?
      gift_card_redesign = ENV['GIFT_CARD_BALANCE']
      gift_card_redesign.nil_or_empty? ? false : true
    end

    def self.noscript?
      !ENV['NOSCRIPT'].nil_or_empty?
    end

    def self.akamai?
      ENV['AKAMAI'] =~ /true/i
    end

    def self.allow_chat?
      ENV['CHAT'] =~ /true/i
    end
  end

  def requested_release
    ENV['RELEASE'].upcase
  end

  def requested_site
    ENV['SITE'].upcase
  end

  #
  # Flag used to perform a series of tests in a single browser session.
  # Currently used in Tablet/Mobile where tearing down simulators causes performance/stability issues.
  #
  def single_session?
    ENV['SINGLE_SESSION'].nil? ? false : ENV['SINGLE_SESSION'].upcase == 'TRUE'
  end

  def target_device
    ENV['DEVICE']
  end

  # Providing appium instance for running in different devices
  def get_appium_instance
    ENV['APP_URL'].nil? ? 'http://127.0.0.1:4723/wd/hub' : ENV['APP_URL']
  end

  def sauce?
    !ENV["SAUCE_USERNAME"].nil_or_empty? && !ENV["SAUCE_ACCESS_KEY"].nil_or_empty?
  end

  def charles_proxy_sleep
    ENV['CHARLES_SLEEP'] ? ENV['CHARLES_SLEEP'].to_i : 5
  end

  def service_disabled?
    ENV['USE_SERVICE'] == false || ENV['USE_SERVICE'].nil?
  end

  def running_on_jenkins?
    !ENV['JENKINS_HOME'].nil_or_empty?
  end

  def mock_sdp_host
    ENV['mock_sdp_host']
  end

  def service_test?
    ENV['SERVICE_TEST'].nil? ? false : ENV['SERVICE_TEST'].upcase == 'TRUE'
  end

  # Returns the root path of the automation repo
  def root
    Pathname.new File.expand_path('../../', File.dirname(__FILE__))
  end

  def jboss?
    !("#{ENV['JBOSS']}".downcase == 'false')
  end

  def tag_override?
    ENV['tagOverride'].nil? ? false : ENV['tagOverride'].upcase == 'TRUE'
  end

  def appium?
    ENV['APPIUM'].nil? ? false : ENV['APPIUM'].upcase == 'TRUE'
  end

end

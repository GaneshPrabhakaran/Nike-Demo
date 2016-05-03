class MobileBrowser
  class << self
    def quit_browser
      @browser.quit unless @browser.nil?
    end

    def close_browser
      @browser.close unless @browser.nil?
    end

    def start
      @device_type = ''

      if ENV['DEVICE'].blank?
        Log.instance.info 'No DEVICE set, using ChromeIphone'
        @device_type = 'ChromeIphone'
      else
        @device_type = ENV['DEVICE'].downcase.include?('sauce') && !ENV['DEVICE'].downcase.include?('saucechromeiphone') ? 'SauceLabsDevices' : ENV['DEVICE']
      end

      @browser = "MobileDevice::#{@device_type}".constantize.new.browser

      # Ensure Marketorial screen is not shown
      @browser.navigate.to ENV['URL'].split('.com')[0] + '.com/us/en_us/'
      @browser.execute_script "(function() { if(typeof(localStorage) !== 'undefined') { window.localStorage.setItem('marketorialShown', '1'); }})();" unless !ENV['DEVICE'].nil? && ENV['DEVICE'].downcase.include?('sauceiphone') # this call fails on actual iOS devices
      @browser
    end

    def reset_browser_session
      Cookies.new(@browser).delete_user_session_cookies
      # We want to attempt to delete the cookies that are on a diff domain. If we are on m2qa1.xxx,
      # the appium does not delete the cookies on m.xxx or .xxx.
      domains_to_be_cleared = [".#{ExecutionEnvironment.host}", ExecutionEnvironment.host_name, '.fds.com']

      domains_to_be_cleared.each do |_domain|
        cookies = @browser.manage.all_cookies.map { |cookie| cookie[:name] }
        cookies.each do |cookie_name|
          # DO NOT REMOVE
          # If removed, it will keep prompting you for the RACF ID/password from the devices. Need alternate solution to this.
          next if %w(FORWARDPAGE_KEY fsr.r fsr.s).include?(cookie_name)

          # browser.execute_script "document.cookie = '#{cookie_name}=; domain=#{domain}; expires=' + new Date(0).toUTCString();"
          @browser.manage.delete_cookie(cookie_name)
        end
      end

      # Clearing local storage
      manage_local_storage

      # DO NOT REMOVE
      # We are resetting all the app variables by simply performing a reload. Do not remove.
      @browser.navigate.refresh
    end

    def manage_local_storage
      @browser.execute_script "(function () { window.localStorage.removeItem('reviewNickname'); })();"
    end
  end
end

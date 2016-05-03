require 'uri'
require 'json'
require 'erb'
include ERB::Util

class Cookies
  def initialize(browser)
    @browser = browser
  end

  #
  # Creates a cookie with the specified data.  The domain, path, expires, and secure
  # fields can be omitted and will contain default values.
  #
  # @param [Hash] cookie Keys: :name, :value, :domain, :path, :expires, :secure
  # @return [Hash] The created cookie data.
  #
  # @example
  #   Cookies.create(name: 'name', :value => 'value', :domain => 'domain', :path => '/')
  #   Cookies.create(name: 'name', :value => 'value')
  #
  def create(cookie)
    Log.instance.debug "Setting cookie: #{cookie}"
    host = nil
    Selenium::WebDriver::Wait.new(:timeout => 120).until{ !(host = @browser.current_url.split("#")[0]).nil? }
    host = URI(host).host
    host = '' if host.nil?
    host = host[/www1?(.*)/, 1]
    cookie = {:path => '/', :domain => host}.merge(cookie)
    Log.instance.debug "Adding cookie #{cookie}"
    if ExecutionEnvironment.browser_name == :ie
      @browser.execute_script('document.cookie="' + create_cookie_js_script(cookie) + '"')
    else
      @browser.manage.add_cookie cookie
    end
    cookie
  end

  def create_cookie_js_script cookie
    c_values = cookie.reject{|k, v| k == :name || k==:value}
    c_values = c_values.map{|i| i.join('=')}
    cookie[:name] + '=' + cookie[:value].to_s.gsub('"', '\"') + '\;' + c_values.join('\;')
  end
  #
  # Deletes all cookies that match the search parameters.
  # @param [Hash] search_cookie Keys: :name, :value
  # @return [Array, Hash] An array of cookie data for cookies that were deleted.
  #
  # @example
  #   cookies = Cookies.delete(name: 'shippingCountry')
  #   cookies   # => [ { name: 'shippingCountry', value: 'US', path: '/', ... }]
  #
  def delete(search_cookie)
    cookies = find(search_cookie)
    cookies.each do |cookie|
      Log.instance.debug "Deleting cookie #{cookie}"
      if ExecutionEnvironment.browser_name == :ie
        @browser.execute_script('document.cookie="' + cookie[:name] + '=' + cookie[:value].to_s.gsub('"', '\"') + '\;' + create_cookie_js_script(cookie) + '\;expires=" + new Date(new Date().getTime() - 24*60*60*1000).toGMTString()')
      else
        @browser.manage.delete_cookie(cookie[:name])
      end
    end
    cookies
  end

  #
  # Finds all cookies that match the specified values.
  # @param [Hash] search_cookie Keys: :name, :value
  # @return [Array, Hash] An array of matching cookies.
  #
  # @example
  #   cookies = Cookies.find(name: 'shippingCountry')
  #   cookies   # => [ { name: 'shippingCountry', value: 'US', path: '/', ... }]
  #
  def find(search_cookie)
    Log.instance.debug "Finding cookies that match #{search_cookie}"
    cookies = @browser.manage.all_cookies.select do |cookie|
      search_cookie.all? { |key, value| cookie[key] == value }
    end
    cookies.nil? ? [] : cookies
  end

  # Returns all of the browser cookies.
  def all()
    find({})
  end

  def update(search_cookie, updated_cookie)
    Log.instance.debug "Updating cookies that match #{search_cookie} with #{updated_cookie}"
    cookies = find(search_cookie)
    cookies.each do |cookie|
      merged_cookie = cookie.merge(updated_cookie)
      delete(cookie)
      create(merged_cookie)
    end
  end

  def tablet_cookie_value?
    Log.instance.debug "TABLET COOKIE: #{@browser.manage.cookie_named("MISCGCs")[:value]}"
    if @browser.manage.cookie_named("MISCGCs")[:value].include? "DT1_92_Tablet"
      return true
    else
      return false
    end
  rescue NoMethodError
    return false
  end

  def set_tablet_cookie_value(bool)
    if @browser.manage.cookie_named("MISCGCs") != nil
      if @browser.manage.cookie_named("MISCGCs")[:value].include? "TABLET"
        cookie_value = @browser.manage.cookie_named("MISCGCs")[:value].gsub("TABLET_92_" + (!bool).to_s,"TABLET_92_" + bool.to_s)
      else
        cookie_value = @browser.manage.cookie_named("MISCGCs")[:value] + "3_87_TABLET_92_" + bool.to_s
      end
      Log.instance.info "TABLET cookie value is: " + @browser.manage.cookie_named("MISCGCs")[:value]
    else
      Log.instance.info "TABLET cookie doesn't exist- we'll create it."
      cookie_value = "TABLET_92_" + bool.to_s
    end
    Log.instance.info "Setting cookie value to: #{cookie_value}"
    create(:name => 'MISCGCs', :value => cookie_value)
  end

  def desktop_cookie_value?
    Log.instance.debug "DESKTOP COOKIE: #{@browser.manage.cookie_named("MISCGCs")[:value]}"
    if @browser.manage.cookie_named("MISCGCs")[:value].include? "DT1_92_PC"
      return true
    else
      return false
    end
  rescue NoMethodError
    return false
  end

  def project_cookie_value
    cookie = @browser.manage.cookie_named("TT")
    if cookie.nil?
      Log.instance.debug "PROJECT COOKIE NOT SET"
      nil
    else
      Log.instance.debug "PROJECT COOKIE VALUE: #{cookie[:value]}"
      cookie[:value]
    end
  end

  def set_project_cookie_value(value)
    if @browser.manage.cookie_named("TT") != nil
      Log.instance.info "Project cookie is already set and the value is: " + @browser.manage.cookie_named("TT")[:value]
    else
      Log.instance.info "Project cookie doesn't exist - we'll create it."
      Log.instance.info "Setting Project cookie value to: #{value}"
      create(:name => 'TT', :value => value)
    end
  end

  def set_sl_cookie_value(value)
    if @browser.manage.cookie_named("SL") != nil
      Log.instance.info "SL cookie is already set and the value is: " + @browser.manage.cookie_named("SL")[:value]
      delete(name: "SL")
    else
      Log.instance.info "SL cookie doesn't exist - we'll create it."
      Log.instance.info "Setting SL cookie value to: #{value}"
    end
    create(:name => 'SL', :value => value)
  end

  def experimentation_cookie_value?(segment)
    Log.instance.debug "Experimentation COOKIE: #{@browser.manage.cookie_named("SEGMENT")[:value]}"
    if (@browser.manage.cookie_named("SEGMENT")[:value].include? "EXPERIMENT") && (@browser.manage.cookie_named("SEGMENT")[:value].include? "#{segment}")
      return true
    else
      return false
    end
  rescue NoMethodError
    return false
  end

  # Given a comma separated string of changes (add,substitute,delete) Update the SEGMENT cookie EXPERIMENTS array
  # Ex. changes='285,301,411:412,D:533
  #   This will add 285, add 301, change 411 to 412, delete 533
  def update_segment_cookie_experiments(changes)
    experiments = get_segment_experiments
    Log.instance.debug("Initial segment values: #{experiments}")
    changes.split(',').each do |change|
      if change.start_with?('D:')
        experiments.delete(change.sub('D:','').to_i)
      elsif change.include?(':')
        find,replace = change.split(':')
        experiments.map! {|x| x == find.to_i ? replace.to_i : x }
      else
        experiments << change.to_i
      end
    end
    experiments.uniq!
    experiments.sort!
    set_segment_experiments(experiments)
    Log.instance.debug("Update Segment Cookie Experiments(#{changes}) => '#{experiments}'")
    Log.instance.debug("Ending segment values: #{get_segment_experiments}")
  end

  # Returns an integer array containing the SEGMENT cookie EXPERIMENTS array
  def get_segment_experiments
    cookie = @browser.manage.cookie_named("SEGMENT")
    segment = cookie.nil? ? nil : cookie[:value]
    if segment.nil?
      Log.instance.debug("SEGMENT cookie not found!")
      []
    else
      decoded = URI.decode(segment)
      evaled = eval(decoded.gsub('"',''))
      if evaled.kind_of?(Hash) && evaled[:EXPERIMENT] && evaled[:EXPERIMENT].kind_of?(Array)
        evaled[:EXPERIMENT]
      else
        Log.instance.debug("SEGMENT cookie not a Hash with EXPERIMENT!")
        []
      end
    end
  end

  # Given an integer array of experiment IDs, sets the SEGMENT cookie EXPERIMENTS array
  def set_segment_experiments(experiments)
    decoded = "{\"EXPERIMENT\":#{experiments.to_s.gsub(' ','')}}"
    segment = URI.encode(decoded,'{[,:""]}')
    delete(name: "SEGMENT") if @browser.manage.cookie_named("SEGMENT")
    create(:name => 'SEGMENT', :value => segment)
  end

  def set_experiment_cookie_value(value)
    if @browser.manage.cookie_named("SEGMENT") != nil
      if @browser.manage.cookie_named("SEGMENT")[:value].include? value
        Log.instance.info "Segment cookie is already set and the value is #{value}"
        return
      end
    else
      Log.instance.info "Segment cookie doesn't exist - we'll create it."
    end
    Log.instance.info "Setting Segment cookie value to: #{value}"
    create(:name => 'SEGMENT', :value => value)
  end

  def disable_gamification_profile_experiment
    if ExecutionEnvironment.macys?
      if @browser.manage.cookie_named("SEGMENT") != nil
        cookie_value = @browser.manage.cookie_named("SEGMENT")[:value]
        if cookie_value.include? "329"
          return
        else
          delete(name: "SEGMENT")
          if cookie_value.include? "330"
            create(:name => 'SEGMENT', :value => cookie_value.sub("329","330"))
          elsif cookie_value.include? "331"
            create(:name => 'SEGMENT', :value => cookie_value.sub("329","331"))
          elsif cookie_value.include? "332"
            create(:name => 'SEGMENT', :value => cookie_value.sub("329","332"))
          else
            create(:name => 'SEGMENT', :value => cookie_value)
          end
        end
      end
    end
  end


  def disable_radical_pdp_experiment
    if ExecutionEnvironment.macys?
      if @browser.manage.cookie_named("SEGMENT") != nil
        cookie_value = @browser.manage.cookie_named("SEGMENT")[:value]
        if cookie_value.include? "1062"
          return
        else
          delete(name: "SEGMENT")
          if cookie_value.include? "1100"
            create(:name => 'SEGMENT', :value => cookie_value.sub("1100","1062"))
          else
            create(:name => 'SEGMENT', :value => cookie_value)
          end
        end
      end
    end
  end


  def tablet_width_height_set?(dsh,dsw)
    Log.instance.debug "TABLET COOKIE: #{@browser.manage.cookie_named("MISCGCs")[:value]}"
    if (@browser.manage.cookie_named("MISCGCs")[:value].include? "DT1_92_Tablet") && (@browser.manage.cookie_named("MISCGCs")[:value].include? "DSW1_92_#{dsw}") && (@browser.manage.cookie_named("MISCGCs")[:value].include? "DSH1_92_#{dsh}")
      return true
    else
      return false
    end
  rescue NoMethodError
    return false
  end

  def print_all_cookies()
    cookies = @browser.manage.all_cookies.select do |cookie|
      Log.instance.debug "Cookie name:#{cookie[:name]} Cookie value: #{cookie[:value]}"
    end
  end

  def set_content_msp_cookie_value(value)
    #Commenting for now to test 100% traffic
    msp_cookie = @browser.manage.cookie_named('QE_TEST')
    if msp_cookie.nil? || msp_cookie[:value] != value
      Log.instance.info "Setting msp cookie value to: #{value}"
      create(:name => 'QE_TEST', :value => value)
    end
  end

  def disable_foresee_survey
    if find(:name => 'fsr.o').empty?
      fsr_r = { d:365, i:"d036702-53369766-67bf-6dea-4b996", e:1408990569653 }
      fsr_s = { v2:-2, v1:1, rid:"d036702-53369766-67bf-6dea-4b996",
                cp: {isAuthenticated:"none"},
                to:3,
                c: ExecutionEnvironment.url,
                pv:1,
                lc: { d0: { v:1, s:false } },
                cd:0
      }
      create(:name => 'fsr.o', :value => 365, :expires => DateTime.now + 365)
      create(:name => 'fsr.r', :value => fsr_r.to_json, :expires => DateTime.now + 365)
      create(:name => 'fsr.s', :value => fsr_s.to_json, :expires => DateTime.now + 365)
    end
  end

  def disable_monetate
    if find(:name => 'mt.s-lbx').empty?
      create(:name => 'mt.s-lbx', :value => 8, :expires => DateTime.now + 365)
    end
    if find(:name => 'mt.i-lbx').empty?
      create(:name => 'mt.i-lbx', :value => 100, :expires => DateTime.now + 365)
    end
  end

  def disable_browser_warning
    return unless ExecutionEnvironment.browser_name == :firefox
    miscgcs_cookie = @browser.manage.cookie_named('MISCGCs')
    if miscgcs_cookie.nil?
      create(:name => 'MISCGCs', :value => 'DBN1_92_Firefox3_87_DMN1_92_353_87_brversion1_92_Firefox', :expires => DateTime.now + 365)
    else
      unless miscgcs_cookie.include?('brversion1')
        create(:name => 'MISCGCs', :value => miscgcs_cookie[:value] + '_DBN1_92_Firefox3_87_DMN1_92_353_87_brversion1_92_Firefox', :expires => DateTime.now + 365)
      end
    end
  end

  def disable_tablet_ui
    if @browser.manage.cookie_named("SEGMENT") != nil
      Log.instance.info "Current SEGMENT cookie value is: " + @browser.manage.cookie_named("SEGMENT")[:value]
      if @browser.manage.cookie_named("SEGMENT")[:value].include? "C71"
        Log.instance.info "Tablet UI is already disabled by default"
        return
      else
        Log.instance.info "Changing segment cookie value to disable Tablet UI"
        create(:name => 'SEGMENT', :value => @browser.manage.cookie_named("SEGMENT")[:value].sub("C70","C71"))
        return
      end
    else
      Log.instance.info "Segment cookie doesn't exist - we'll create it and disable Tablet UI"
      create(:name => 'SEGMENT', :value => '71')
    end
  end

  def delete_user_session_cookies
    Log.instance.debug "Deleting any previous user session cookies."
    ExecutionEnvironment.mew_mock? ? (domain = nil) : (domain = URI.parse(ExecutionEnvironment.url).host.gsub('www.',''))
    if macys?
      @browser.get(ExecutionEnvironment.url) unless @browser.current_url.include?(domain)
      create(:name => 'macys_online_uid', :value => '0', :domain => domain, :expires => DateTime.now - 365) if find(:name => 'macys_online_uid')
    else
      @browser.get(ExecutionEnvironment.url) unless @browser.current_url.include?(domain)
      create(:name => 'bloomingdales_online_uid', :value => '0', :domain => domain, :expires => DateTime.now - 365) if find(:name => 'bloomingdales_online_uid')
    end
  end

  def set_and_get_cookie_values
    mcom_cookie_value = {"RC" => "1065", "NON-RC" => "1064"}
    bcom_cookie_value = {"RC" => "1098", "NON-RC" => "1097"}
    @env_cookie = ExecutionEnvironment.macys? ? mcom_cookie_value : bcom_cookie_value
  end

  def enable_or_disable_responsivecheckout_cookie(cookie_value)
    old_value,new_value = "", ""
    if @browser.manage.cookie_named("SEGMENT") != nil
      if @browser.manage.cookie_named("SEGMENT")[:value].include? cookie_value
        Log.instance.info "Given Cookie value is already set by default"
        return
      else
        Log.instance.info "Changing segment cookie value to enable/diable Responsive Checkout"
      case cookie_value
        when "1065"
          old_value,new_value = "1064", "1065"
        when "1095"
          old_value,new_value = "1096", "1095"
        when "1096"
          old_value,new_value = "1095", "1096"
        when "1098"
          old_value,new_value = "1097", "1098"
        when "1097"
          old_value,new_value = "1098", "1097"
      end
        create(:name => 'SEGMENT', :value => @browser.manage.cookie_named("SEGMENT")[:value].sub(old_value,new_value))
        return
      end
    end
  end

  def disable_responsive_checkout
    set_and_get_cookie_values
    if @browser.manage.cookie_named("SEGMENT") != nil
      if @browser.manage.cookie_named("SEGMENT")[:value].include? @env_cookie["NON-RC"]
        Log.instance.info "Responsive Checkout is already turned off"
        return
      else
        value = @browser.manage.cookie_named("SEGMENT")[:value]
        Log.instance.info "Changing segment cookie value to disable Responsive Checkout"
        delete(:name => 'SEGMENT')
        update_cookie_value = value.gsub(@env_cookie["RC"],@env_cookie["NON-RC"])
        create(:name => 'SEGMENT', :value => update_cookie_value)
        return
      end
    end
  end

  def is_rc_cookie_enabled?
    set_and_get_cookie_values
    if @browser.manage.cookie_named("SEGMENT") != nil
      if @browser.manage.cookie_named("SEGMENT")[:value].include? @env_cookie["RC"]
        #Log.instance.info "Responsive Checkout Cookie is enabled"
        return true
      elsif @browser.manage.cookie_named("SEGMENT")[:value].include? @env_cookie["NON-RC"]
        #Log.instance.info "Responsive Checkout Cookie is disabled"
        return false
      end
    else
      Log.instance.info "No SEGMENT Cookie is exists"
      return false
    end
  end

  def mew_disable_foresee
    create(:name => 'fsr.r', :value => '{\"d\":90,\"i\":\"de25df2-105324912-a3ea-edc0-dcdd0\",\"e\":1406678138341}', :path => '/', :secure => false)
    create(:name => 'fsr.s', :value => '{\"v\":1,\"rid\":\"de25df2-105324912-a3ea-edc0-dcdd0\",\"cp\":{\"isAuthenticated\":\"none\",\"MEW_2_0\":\"2.0\",\"Currency\":\"false\",\"Shipping_Country\":\"false\"},\"to\":3.1,\"c\":\"#{ExecutionEnvironment.host_name}\",\"pv\":10,\"lc\":{\"d0\":{\"v\":10,\"s\":true}},\"cd\":0,\"sd\":0,\"l\":\"en\",\"i\":-1,\"f\":1406073395349}', :path => '/', :secure => false)
  end

end

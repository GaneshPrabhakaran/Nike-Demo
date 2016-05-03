class Proxy
  require 'browsermob/proxy'
  require 'socket'



  def self.start_proxy
    # Adding retries in case of port collision
    retries = 2
    begin
      server = BrowserMob::Proxy::Server.new(ExecutionEnvironment.proxy_path, log: true, port: ephemeral_port, timeout: 30)
      server.start
    rescue Errno::EADDRINUSE
      raise $! if retries == 0
      retries -= 1
      retry
    end

    @proxy = server.create_proxy #=> #<BrowserMob::Proxy::Client:0x0000010224bdc0 ...>
    # @proxy.blacklist(%r!https://.*/EventsWar/events/record/customeraction!, 404)
    # @proxy.blacklist(%r!https?://connect.facebook.com/en_US/.*.js!, 404)
    # @proxy.blacklist(%r!http://.*/sdp/rto/request/recommendations!, 404)

    # Check if RTO_FAILURE env variable is set as true
    if ExecutionEnvironment.force_rto_failure?
      blacklist_rto_call
    end
    @proxy.new_har "capture"
    @proxy
  end

  # Add rto endpoint to proxy blacklist
  def self.blacklist_rto_call
    @proxy.blacklist(%r!http://.*/sdp/rto/request/recommendations!, 404)
    @proxy
  end

  def self.close_proxy
    raise "The proxy was not started. To run a test with the proxy pass the following into the command line: PROXY=true" if @proxy.nil?
    get_har_segment(true)
    @segment = nil
    @har_file = nil
    @proxy.close
    @proxy = nil
  end

  def self.log_har_to_file(har_data)
    har_file_path = get_har_file_path
    Log.instance.debug("PROXY_LOG: (#{File.exist?(har_file_path) ? 'APPEND' : 'CREATE'}) #{har_file_path}")
    File.open(har_file_path, 'a') { |io| io << har_data.to_json }
  end

  def self.get_har_file_path
    unless @har_file
      @har_file = "#{ExecutionEnvironment.log_directory}/network_capture_#{Log.instance.timestamp}.har"
      @har_file.gsub!('/', '\\') if ExecutionEnvironment.host_os == :windows
    end
    @har_file
  end

  def self.get_har_segment(start_new = false)
    if @proxy.nil?
      Log.instance.debug('The proxy was not started.' )
      nil
    else
      Log.instance.debug "Gathering Network Capture segment"
      wait_for_stable_har
      @segment = @proxy.har
      if start_new
        @proxy.new_har("capture")
        log_har_to_file(@segment) if ExecutionEnvironment.proxy_enabled?('LOGGING')
      end
      @segment
    end
  end

  def self.wait_for_stable_har
    cnt = 0
    begin
      before = @proxy.har.entries.size
      sleep 1
      after = @proxy.har.entries.size
      cnt += 1
      Log.instance.debug "Proxy.get_har_segment.wait:(#{before},#{after})"
    end until after == before and cnt<10
  end

  def self.start_new_segment
    @segment = @proxy.har
    @proxy.new_har("capture")
  end

  def self.check_entry_for_tag(har_entries, tag_data)
    coremetrics_tags = HarManager.search_url(har_entries, ".com/cm?")

    raise 'Coremetrics tag is malformed. Must contain "must_have" or "must_not_have" or both.' unless tag_data.has_key?("must_have") || tag_data.has_key?("must_not_have")

    # log_entries is undefined, hence commented it, until it is fixed
    # HarManager.log_entries(coremetrics_tags)

    if tag_data.has_key?("must_have")
      tag_data["must_have"].each do |key, value|
        coremetrics_tags = HarManager.search_entries(coremetrics_tags, key, value)
        raise "The specified CoreMetrics tag '#{tag_data["tag_name"]}' was not found or did not contain '#{key}': '#{value}'" if coremetrics_tags.empty?
      end
    end

    if tag_data.has_key?("must_not_have")
      tag_data["must_not_have"].each do |key, value|
        tmp_coremetrics_tags = HarManager.search_entries(coremetrics_tags, key, value)
        raise "The specified CoreMetrics tag #{tag_data["tag_name"]} contained '#{key}': '#{value}'" unless tmp_coremetrics_tags.empty?
      end
    end

    Log.instance.info "Validated Coremetrics tag '#{tag_data["tag_name"]}'"
  end

  def self.ephemeral_port
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    port
  ensure
    server.close unless server.nil?
  end
end

module Triage
  class TimeoutTriage

    # This timeout is on top of the PageObject page load timeout.
    attr_reader :dom_ready_state_timeout

    def self.process_recovery(browser, error = nil)
      Log.instance.warn(error) if error
      this = TimeoutTriage.new browser
      this.log_dom_ready_state_definitions
      this.wait_for_dom_ready_state_complete
      Log.instance.debug 'The document appears to be ready. Continuing test execution...'
    end

    def self.recovered_timeouts_log_file
      File.join(File.dirname(Log.instance.log_file_path), 'recovered-timeouts45.log')
    end

    def initialize(browser)
      @browser = browser
      @dom_ready_state_timeout = 45
    end

    def dom_ready_state_complete?
      state = @browser.execute_script('return document.readyState;') rescue -1
      Log.instance.debug "document.readyState: #{state}"
      state == 'complete'
    end

    def wait_for_dom_ready_state_complete
      end_time = ::Time.now + @dom_ready_state_timeout
      until ::Time.now > end_time
        #state = @browser.execute_script('return document.readyState;') rescue 'error retrieving readyState'
        begin
          if @browser.respond_to? :execute_script
            state = @browser.execute_script('return document.readyState;')
          else
            state = @browser.executeScript('return document.readyState;')
          end
        rescue => e
          Log.instance.error "Received error in executing JavaScript: #{e}"
        end

        Log.instance.debug "document.readyState: #{state}"
        if state == "complete"
          File.open(TimeoutTriage.recovered_timeouts_log_file, 'a') do |io|
            io << "#{Log.instance.timestamp}: Recovered from timeout.  Log file: #{Log.instance.log_file_path}\n"
          end
          return
        end
        sleep 2
      end
      File.open(TimeoutTriage.recovered_timeouts_log_file, 'a') do |io|
        io << "#{Log.instance.timestamp}: Failed to recover from timeout.  Log file: #{Log.instance.log_file_path}\n"
      end
      raise Timeout::Error, "document.readyState never reached 'complete' within #@dom_ready_state_timeout seconds."
    end

    def window_loaded?
      if ExecutionEnvironment.macys?
        script = "
          window.__windowLoaded = false;
          if (window.jQuery) {
            jQuery(window).load(function() { window.__windowLoaded = true; })
          }
          else {
            window.__windowLoaded = true;
          }
          return window.__windowLoaded;
        "
      else
        script = "
          document.__ready = false;
          if (window.jQuery) {
            jQuery(document).load(function() { document.__ready = true; })
          }
          else {
            document.__ready = true;
          }
          return document.__ready;
        "
      end

      window_loaded = @browser.execute_script(script) rescue -1
      Log.instance.debug "Window loaded? #{window_loaded}"
      window_loaded == true
    end

    def log_dom_ready_state_definitions
      Log.instance.debug ""
      Log.instance.debug "Logging document.readyState.  Value definitions:"
      Log.instance.debug "   loading:     the Document is loading"
      Log.instance.debug "   interactive: the Document has finished parsing but is still loading sub-resources (AKA DOMContentLoaded)"
      Log.instance.debug "   complete:    the Document is loaded as well as all sub-resources (AKA window onLoad)"
    end


    def log_document_state
      log_dom_ready_state_definitions
      10.times do
        state = @browser.execute_script('return document.readyState;') rescue 'error retrieving readyState'
        Log.instance.debug "document.readyState: #{state}"
        return if state == "complete"
        sleep 2
      end
    end

    def log_document_images
      Log.instance.debug ""
      Log.instance.debug "Logging document.images.  The value after colon refers to whether the image is loaded or not."
      script = 's = ""; for (i=0; i<document.images.length; i++) { s += document.images[i].src + " : " + document.images[i].complete + "\n"; } return s;'
      images = @browser.execute_script(script) rescue 'error retrieving document images'
      Log.instance.debug "document.images:\n#{images}"
    end

    def log_document_css
      Log.instance.debug ""
      Log.instance.debug "Logging CSS files."
      script = 's = ""; for (i=0; i<document.styleSheets.length; i++) { s += document.styleSheets[i].href + "\n"; } return s;'
      css = @browser.execute_script(script) rescue 'error retrieving document css'
      Log.instance.debug "CSS:\n#{css}"
    end

    def log_javascript_files
      Log.instance.debug ""
      Log.instance.debug "Logging document.getElementsByTagName('script')."
      script = 'ret = ""; var it = Iterator(document.getElementsByTagName("script")); for (let [i,s] in it) { ret += s.getAttribute("src") + "\n"; } return ret;'
      js = @browser.execute_script(script) rescue 'error retrieving javascript files'
      Log.instance.debug "javascript files:\n#{js}"
    end

    def log_cpu_load
      if [:linux, :maxosx].include? ExecutionEnvironment.host_os
        output = `top -b -n 1 | head -n 12` rescue nil
        Log.instance.debug ""
        Log.instance.debug "CPU Load:\n#{output}"
      else
        Log.instance.debug "Unable to log CPU load for non-Linux test host."
      end
    end

    def log_loading_events
      # Insert JS to start capturing ajax and window load events
      inserted_ajax = @browser.execute_script('window.__completedAjax = ""; jQuery(document).ajaxComplete(function(event, request, settings) { window.__completedAjax += settings.url + ";"; })') rescue -1
      if ExecutionEnvironment.macys?
        inserted_load = @browser.execute_script('window.__windowLoaded = false; jQuery(window).load(function() { window.__windowLoaded = true; })') rescue -1
      else
        inserted_load = -1
      end

      Log.instance.debug "Inserted ajaxComplete handler" unless inserted_ajax == -1
      Log.instance.debug "Inserted window load handler" unless inserted_load == -1
      return if inserted_ajax == -1 && inserted_load == -1

      ajax_completed = inserted_ajax == -1 ? true : false
      load_completed = inserted_load == -1 ? true : false
      end_time = ::Time.now + 120
      until ::Time.now > end_time
        if inserted_ajax != -1 && !ajax_completed
          Log.instance.debug "Checking for completed ajax requests..."
          completed = @browser.execute_script('return window.__completedAjax;') rescue nil
          Log.instance.debug "Completed ajax calls: [#{completed}]"
          pending_requests = @browser.execute_script(::PageObject::Javascript::JQuery.pending_requests) rescue -1
          Log.instance.debug "#{pending_requests} pending requests remain."
          ajax_completed = pending_requests < 1
        end

        if inserted_load != -1 && !load_completed
          Log.instance.debug "Checking for window load event..."
          loaded = @browser.execute_script('return window.__windowLoaded;')
          Log.instance.debug "Has window load event occurred? #{loaded}"
          load_completed = loaded == true || loaded == "true"
        end

        break if ajax_completed && load_completed
        sleep 2
      end
    rescue => error
      Log.instance.warn "Error checking for loading: #{error}"
    end

  end
end

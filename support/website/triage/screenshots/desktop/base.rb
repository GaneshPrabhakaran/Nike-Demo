module Triage
  module Screenshots
    module Desktop
      class Base
        def initialize(timestamp)
          @timestamp = timestamp
        end

        def take_screenshot
          raise "The derived class must implement the take_screenshot method."
        end

        def screenshot_path
          @screenshot_path ||= "#{ExecutionEnvironment.log_directory}/screenshot_desktop_#{@timestamp}.jpg"
        end
      end
    end
  end
end

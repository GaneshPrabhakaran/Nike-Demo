module Cucumber
  module Formatter
    # Defines the non-api methods used by the Json formatter.
    class Json
      protected

      def expanding?; @outline && @options[:expand] && @expanding end

      def scenario; @nested_element || @element end

      def match(step_match)
        match = { 'location' => step_match.file_colon_line }
        match['arguments'] = step_match.step_arguments.map(&:to_hash) unless step_match.step_arguments.empty?
        match
      end

      def set_status(status, exception = nil)
        @hook['result'] = { 'status' => status }
        @hook['result']['error_message'] = exception_message exception if exception
      end

      def exception_message(error); %(#{"#{error.class}::" unless error.instance_of? RuntimeError}#{error.message}) end

      def duration(start); ((Time.now - start) * 1_000).to_i end # Convert seconds to milliseconds.

      def elements; @feature['elements'] ||= []  end

      def tags;     @hook['tags'] ||= []        end

      def examples; scenario['examples'] ||= []  end

      def cells;    @row['cells'] ||= []         end

      def steps;    scenario['steps'] ||= []     end

      def files;    (@row || scenario)['files'] ||= [] end

      def rows;     (@multiline_arg ? @step : @example)['rows'] ||= [] end
    end # Json
  end # Formatter
end # Cucumber

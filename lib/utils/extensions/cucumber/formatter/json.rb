require 'cucumber/formatter/json'
require 'cucumber/formatter/json_pretty'
require 'cucumber/formatter/io'

module Cucumber
  # The formatters used to output the results of walking the AST.
  module Formatter
    # Undefine the existing JSON formatters
    remove_const :Json
    remove_const :JsonPretty

    # Defines a Cucumber formatter that outputs in a JSON format.
    # Output is assembled into a Hash, then processed by the JSON generator on completion.
    class Json
      include Io

      def initialize(runtime, path_or_io, options)
        @runtime = runtime
        @io = ensure_io path_or_io, 'json'
        @options = options
        @expanding = false
      end

      # 'files': [{ 'name': 'Cucumber Log', 'mime': 'text/plain', 'file': 'cucumber.log' }]
      def embed(src, mime_type, name); files.push 'name' => name, 'mime' => mime_type, 'file' => File.basename(src) end

      def before_features(_feature_set); @result_set = [] end

      def after_features(_feature_set); @io.write JSON.generate(@result_set) end

      def before_feature(feature)
        @feature_start = Time.now
        @feature_tags = feature.source_tags
        @result_set.push(@feature = @hook = feature.gherkin_statement.to_hash)
        @feature['uri'] = feature.file
        convert_id @feature
      end

      def after_feature(_feature) @feature['duration'] = duration @feature_start end

      def before_background(background) elements.push(@element = @hook = background.gherkin_statement.to_hash) end

      def before_feature_element(feature_element)
        @element_start = Time.now
        @element = @hook = feature_element.gherkin_statement.to_hash
        convert_id @element
        tags.concat @feature_tags.map(&:to_hash)
        @outline = feature_element.is_a? Ast::ScenarioOutline
        @expanding = false if @outline && @options[:expand]
        elements.push @element unless @outline && @options[:expand]
      end

      def after_feature_element(_element) scenario['duration'] = duration @element_start end

      def scenario_name(_keyword, _name, _file_colon_line, _source_indent)
        return unless expanding?
        @example_row = 0 if @reset_rows
        @reset_rows = false
        example_row = @example['rows'][@example_row += 1]
        @nested_element = @hook = {
          'comments' =>     @element['comments'],     'tags' => @element['tags'], 'keyword' =>  @element['keyword'],
          'description' =>  @element['description'],  'name' => @element['name'], 'type' =>     'scenario',
          'line' =>         example_row['line'],      'id' =>   example_row['id']
        }
        convert_id @nested_element
        elements.push @nested_element
      end

      def before_step(step)
        @step_start = Time.now
        steps.push(@step = @hook = step.gherkin_statement.to_hash)
        @step_line = step.gherkin_statement.line
      end

      def after_step(_step); @step['result']['duration'] = duration @step_start if @step.key? 'result' end

      def before_examples(example_set)
        @example = @hook = example_set.gherkin_statement.to_hash
        convert_id @example
        if @options[:expand]
          @expanding = @reset_rows = true
        else
          @example['rows'].clear
          examples.push @example
        end
      end

      def after_examples(_example_set); @nested_element = @current_sub_step = nil end

      # rubocop:disable Metrics/ParameterLists
      def step_name(_keyword, step_match, _status, _source_indent, _background, _file_colon_line)
        return unless expanding?
        @step['name'] = step_match.format_args
        @step['match'] = @current_step_match
        @step['result'] = @current_step_result
      end

      def before_step_result(_keyword, step_match, _multiline_arg, status, exception, _indent, _background, _line)
        current_match = match step_match
        if expanding?
          @current_step_match = current_match
          @current_step_result = { 'status' => status }
          @current_step_result['error_message'] = exception_message exception if exception
        elsif !@outline
          set_status status, exception
          @step[:match] = current_match
        end
      end
      # rubocop:enable Metrics/ParameterLists

      def before_multiline_arg(_multiline); @multiline_arg = true end

      def after_multiline_arg(_multiline); @multiline_arg = false end

      def before_table_row(row)
        @row_start = Time.now
        @row = @hook = {}
        @row[:line] = (@step_line += 1) if @multiline_arg
        unless @multiline_arg || expanding?
          @row['line'] = row.line
          @row['id'] = "#{@example['id']}_#{row.instance_variable_get(:@table).index(row) + 1}".gsub ';', '_'
        end
        rows.push @row
      end

      def after_table_row(row)
        return if @multiline_arg
        set_status row.status, row.exception
        @hook['result']['duration'] = duration @row_start
      rescue NoMethodError, Ast::OutlineTable::ExampleRow::InvalidForHeaderRowError
        set_status 'skipped_param' # This is the example set's header row, but we can't know this until it fails. Yay.
      ensure
        @row = nil
      end

      def before_table_cell(cell); cells.push cell.value end

      def convert_id(record); record['id'] = record['id'].gsub ';', '_' end
    end # Json

    # Defines a Cucumber formatter that outputs in a JSON format.
    # Output is assembled into a Hash, then processed by the JSON generator on completion.
    # This variant of Json formats the output to a human-readable state.
    class JsonPretty < Json
      def after_features(_feature_set); @io.write JSON.pretty_generate(@result_set) end
    end # JsonPretty
  end # Formatter
end # Cucumber

require 'cucumber/formatter/html'
require 'fileutils'
require 'htmlentities'

module Cucumber
  module Formatter
    # Overrides the existing Cucumber HTML formatter with tighter formatting.
    # TODO: Rename this back to Html and remove the inheritance once we no longer rely on WDSAutomation.
    class BetterHTML < Cucumber::Formatter::Html
      def before_features(features)
        @step_count = features.step_count

        # <!DOCTYPE html>
        @builder.declare!(:DOCTYPE, :html)
        @builder << '<html>'
        build_head @builder
        @builder << '<body><div class="cucumber">'
        @builder.comment! "Step count #{@step_count}"
        build_site_info
        build_sub_header @builder
      end

      def scenario_name(keyword, name, file_colon_line, _source_indent)
        @listing_background = false
        @expand_row += 1 if @expand_row
        @builder.h3 id: header_id, class: 'scenario-header green' do |h3|
          h3.span keyword + ':', class: 'keyword'
          h3.text! ' '
          h3.span name, class: 'val'
          h3.span(class: 'scenario_file') { |span| span << file_colon_line }
        end
        @builder << %(<div class="scenario-details">#{'<ul>' if @inside_outline})
      end

      def before_feature(feature)
        @exceptions = []
        @builder << %(<div class="feature" id="#{feature.gherkin_statement.id.sub ';', '_'}">)
      end

      def before_feature_element(feature_element)
        @scenario_number += 1
        @scenario_red = false
        @scenario_id = feature_element.gherkin_statement.id.sub ';', '_'
        class_value = "scenario#{' outline' if feature_element.is_a? Ast::ScenarioOutline} collapsed"
        @builder << %(<div class="#{class_value}" id="#{@scenario_id}">)
      end

      def after_feature_element(_feature_element); @builder << '</ul></div></div>' end

      def feature_name(keyword, name)
        lines = name.split(/\r?\n/)
        return if lines.empty?
        @builder.h2 { |h2| h2.span "#{keyword}: #{lines[0]}", class: 'val' }
        @builder.div(class: 'narrative') { |div| div.pre(lines[1..-1].map(&:strip).join "\n") }
      end

      def before_comment(_comment);   @builder << '<div class="comment"><pre>' end

      def comment_line(comment_line); @builder.text!(comment_line.gsub(/^(#\s)*/, '') || comment_line) end

      def after_comment(_comment);    @builder << '</pre></div>' end

      def before_tags(_tags);         @builder << '<div class="tags-container">' end

      def after_tags(_tags);          @builder << '</div>' end

      def before_examples(_examples)
        @outline_red = false
        @builder << '<li class="step message example-container">'
        @builder.h4 'Examples'
        @builder << %(<div class="examples #{@options[:expand] ? 'expand' : 'simple'}" id="#{@scenario_id}_">)
      end

      def after_examples(_examples); @builder << '</div></li>' end

      def before_example(_ex); @builder << %(<div class="example collapsed" id="#{@scenario_id}__#{@expand_row}">) end

      def after_example(_example); @builder << "</ul></div>#{'</div>' if @options[:expand]}" end

      def examples_name(_keyword, _name); end

      def before_steps(_steps); @builder << '<ul>' end

      def after_steps(_steps); @builder << %(</ul>#{'<ul class="embed-container">' unless @in_background}) end

      def before_outline_table(_outline_table)
        @inside_outline = true
        @outline_row = 1
        @expand_row = @options[:expand] ? 2 : nil # Expanded examples skip row 1: the header
        @builder << '<table class="outline">' unless @options[:expand]
      end

      def before_multiline_arg(a); @builder << '<table>' if a.is_a?(Ast::Table) && !@hide_this_step && !@skip_step end

      def after_multiline_arg(a); @builder << '</table>' if a.is_a?(Ast::Table) && !@hide_this_step && !@skip_step end

      def table_cell_value(value, status)
        return if @hide_this_step

        @cell_type = @outline_row == 0 ? :th : :td
        build_cell @cell_type, value, class: %(step#{" #{status}" if status})
        set_scenario_color(status) if @inside_outline && status # Skip nil status.
        @col_index += 1
      end

      def after_outline_table(_outline_table)
        @builder << '</table>' unless @options[:expand]
        @outline_row = nil
        @inside_outline = false
      end

      def before_table_row(_table_row)
        @col_index = 0
        @builder << %(<tr class="step" id="#{@scenario_id}__#{@outline_row}">) unless @hide_this_step
      end

      # rubocop:disable Metrics/ParameterLists
      def before_step_result(_keyword, step_match, _multiline, status, exception, _indent, background, _colon)
        @step_match = step_match
        @hide_this_step = status != :failed && @in_background ^ background
        @exceptions.include?(exception) ? @hide_this_step = true : @exceptions << exception if exception
        return if @hide_this_step

        set_scenario_color(@status = status)
        @builder << %(<li data-location="#{@step_id}" class="step #{status}">)
        @in_step_result = true
      end

      def after_step_result(keyword, step, _multiline, status, _ex, _indent, _background, _colon)
        return if @hide_this_step

        # print snippet for undefined steps
        if status == :undefined
          keyword = @step.actual_keyword if @step.respond_to?(:actual_keyword)
          clazz = @step.multiline_arg ? @step.multiline_arg.class : nil
          @builder.pre { |pre| pre << @runtime.snippet_text(keyword, step.instance_variable_get('@name') || '', clazz) }
        end
        @builder << '</li>'
        @in_step_result = false
        print_messages
      end
      # rubocop:enable Metrics/ParameterLists
    end # BetterHTML
  end # Formatter
end # Cucumber

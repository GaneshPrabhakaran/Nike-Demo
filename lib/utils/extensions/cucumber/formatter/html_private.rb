module Cucumber
  module Formatter
    # Defines the non-api methods used by the BetterHTML formatter.
    # TODO: Rename this back to Html once we no longer rely on the old HTML report.
    class BetterHTML
      def embed(src, mime_type, label)
        src = File.basename(src)
        raw = (mime_type =~ %r{^image\/(png|gif|jpg|jpeg)}).nil?
        type = raw ? 'raw' : 'image'

        @builder.li id: "embed_#{@img_id}", class: "embed #{type}" do |li|
          li.a label || 'Log file', href: src, 'data-for' => "##{type}_#{@img_id}", target: '_blank'
          li.div(id: "#{raw ? 'raw' : 'image'}_#{@img_id}") do |div|
            raw ? div.pre('') : div.img(src: src, alt: label, onerror: 'Cuke.loadFailed(this)')
          end
        end
        @img_id += 1
      end

      protected

      def build_head(buffer)
        buffer.head do |head|
          head.meta charset: 'utf-8'
          head.meta 'http-equiv' => 'X-UA-Compatible', content: 'IE=edge'
          head.meta name: 'viewport', content: 'width=device-width, initial-scale=1'
          head.title 'Cucumber'
          head.style { |style| read_file style, 'resources/cucumber.min.css' }
          head.script { |script| read_file script, 'resources/jquery.min.js', 'resources/cucumber.min.js' }
        end
      end

      def build_sub_header(buffer)
        buffer.div(id: 'sub-header') do |sub|
          build_a_button 'failure-expander', 'Expand Failures'
          build_a_button 'expander', 'Expand All'
          build_a_button 'collapser', 'Collapse All'
          sub.span(id: 'tag-container') do |tag|
            tag.label 'Filter By Tag: ', for: 'tag-filter'
            tag.select(id: 'tag-filter') { |select| select.option 'all' }
          end
        end
      end

      def build_a_button(id, text); @builder.button text, class: 'a', id: id end

      def read_file(buffer, *local_paths); local_paths.each { |path| buffer << File.read(File.join(__dir__, path)) } end

      def build_step(keyword, step_match, status)
        @builder << %(<li id="#{@step_id}" class="step #{status rescue ''}">) unless @in_step_result
        @builder.div class: 'step_name' do |div|
          div.span keyword, class: 'keyword'
          div.span(class: 'step val') { |span| span << build_params(step_match) }
        end

        # Ignoring TM_PROJECT_DIRECTORY directive from original, since we don't use TextMate.
        @builder.div(class: 'step_file') { |div| div.span { |span| span << step_match.file_colon_line } }

        print_messages unless @in_step_result
        @builder << '</li>' unless @in_step_result
      end

      def build_params(match); match.format_args -> (p) { %(<span class="param">#{encoder.encode p}</span>) } end

      def encoder; @encoder ||= HTMLEntities.new end

      def build_cell(type, val, attrs); @builder.__send__(type, attrs) { @builder.span val, class: 'step param' } end

      def build_exception_detail(exception)
        @builder.div(class: 'error-message') { |div| div.pre { |pre| pre << exception_message(exception) } }
        process_backtrace exception
      end

      def exception_message(error); %(#{"#{error.class} - " unless error.instance_of? RuntimeError}#{error.message}) end

      def process_backtrace(exception)
        @builder.div 'Backtrace', class: 'code-toggle collapsed'
        @builder.div(class: 'code-container') do |container|
          container.div(class: 'backtrace') do |back_div|
            back_div.pre do |pre|
              backtrace = exception.backtrace.delete_if { |x| x =~ %r{/gems/(cucumber|rspec)} }.join("\n")
              pre << backtrace_line(concat_lines backtrace)
            end
          end
        end
      end

      def concat_lines(lines); lines.bytesize <= 64_000 ? lines : lines.byteslice(0, 63_997).concat('...') end

      def build_site_info
        @builder.div(id: 'cucumber-header', class: 'green') do |header|
          header.div(id: 'summary') do |summary|
            summary.div(id: 'site-info') { |si| si << ENV['SITE_INFO'].gsub(/(\s*\n)+/, '<br />') } if ENV['SITE_INFO']
            summary.div '', id: 'totals'
            summary.div '', id: 'duration'
          end
          @builder.h1 'Cucumber Features', id: 'label'
        end
      end

      def print_stats(features)
        @builder.script do
          rewrite 'duration', "Finished in #{time features.duration}"
          rewrite 'totals', print_stat_string(features)
        end
      end

      def rewrite(id, text); @builder << "$('##{id}').html('#{text}');" end

      def time(seconds)
        m, s = seconds.divmod 60
        h, m = m.divmod 60 if m >= 60

        format '%d:%02d:%s', (h || 0), m, format('%.3f', s).rjust(6, '0')
      end

      def set_scenario_color_failed; @builder.script { |script| make script, 'red' } end

      def set_scenario_color_pending; @builder.script { |script| make script, 'yellow' } end

      def make(buffer, color)
        # CSS selector '#' is prepended in the JS, don't add it here.
        buffer.text! "Cuke.#{color}('cucumber-header');" unless @header_red
        buffer.text! "Cuke.#{color}('#{outline_id}');" unless @outline_red
        buffer.text! "Cuke.#{color}('#{header_id}');" unless @scenario_red
        @scenario_red = @header_red = @outline_red = true if color.eql? 'red'
      end

      def header_id; "#{outline_id}#{"_#{@options[:expand] ? @expand_row : @outline_row}" if @inside_outline}" end

      def outline_id; "#{@in_background ? 'background' : 'scenario'}_#{@scenario_number}" end

      def move_progress; end
    end # BetterHTML
  end # Formatter
end # Cucumber

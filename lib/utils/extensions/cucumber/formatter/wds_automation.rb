require 'cucumber/formatter/html'

module Cucumber
  module Formatter
    # TODO: Remove in favor of BetterHTML once external resources no longer rely on this.
    class WDSAutomation < Cucumber::Formatter::Html


      def initialize(runtime, path_or_io, options)
        super
      end

      def embed(src, mime_type, label)
        case(mime_type)
          when /^image\/(png|gif|jpg|jpeg)/
            embed_image(src, label)
          when /^text\/plain/
            embed_text(src,label)
        end
      end

      def embed_text(src, label = "Log file")
        id = "img_#{src}"
        @builder.span(:class => 'embed') do |pre|
          pre << %{<div id="#{id}"><a target="_blank" href="#{src}">#{label}</a></div></br>}
        end
      end

      def before_features(features)
        @scenario_tags = []
        @step_count = features.step_count

        # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        @builder.declare!(
            :DOCTYPE,
            :html,
            :PUBLIC,
            '-//W3C//DTD XHTML 1.0 Strict//EN',
            'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        )

        @builder << '<html xmlns ="http://www.w3.org/1999/xhtml">'
        @builder.head do
          @builder.meta('http-equiv' => 'Content-Type', :content => 'text/html;charset=utf-8')
          @builder.title 'Cucumber'
          inline_css
          inline_js
          @builder.script('function toggleDesktopViews(){ $(\'a:contains("Desktop")\').click(); }', :type => 'text/javascript')
        end
        @builder << '<body>'
        @builder << "<!-- Step count #{@step_count}-->"
        @builder << "<!-- HTML sara-->"
        @builder << '<div class="cucumber">'
        @builder.div(:id => 'cucumber-header') do
          @builder.div(:id => 'label') do
            @builder.h1('Cucumber Features')
          end
          @builder.div(:id => 'summary') do
            @builder.p('',:id => 'siteInfo')
			      @builder.p("MOCK_HOST: #{ENV['MOCK_HOST']}", :id => 'mock_host_info') if ENV['MOCK_HOST']
            @builder.p('',:id => 'totals')
            @builder.p('',:id => 'duration')
            @builder.div(:id => 'expand-collapse') do
              @builder.p('Toggle Desktop Views', :id => 'toggleDesktopViews', :onclick => 'toggleDesktopViews()', :style => 'cursor:pointer;')
              @builder.p(' / ')
              @builder.p('Collapse All', :id => 'collapser')
              @builder.p(' / ')
              @builder.p('Expand All', :id => 'expander')
            end
          end
        end
        if  ENV['SITE_INFO']
          s = ENV['SITE_INFO'].gsub("\n", '<br>')
          height = 6.0 + (s.split('<br>').length * 1.4)
          height = "%.2f" %height
          @builder <<  "<script type=\"text/javascript\">document.getElementById('siteInfo').innerHTML = \"#{s}\"; jQuery('.cucumber #cucumber-header, td #cucumber-header, th #cucumber-header').css('height','#{height}em')</script>"
        end
        @builder << '<center><h3><a target="_blank" href="http://confluence/display/PM/Triage+Guide">For help triaging failures click here</a></h3></center>'
      end

      def before_feature(feature)
        @exceptions = []
        @builder << '<div class="feature">'
        @active_tags =[]
        feature.source_tags.each do |tag|
          @active_tags << tag.name
        end
      end

      def before_feature_element(feature_element)
        scene_tag = []
        feature_element.gherkin_statement.tags.each do |tag|
          scene_tag << tag.name
        end
        @active_tags.each do |tag|
          scene_tag << tag
        end
        @scenario_tags << scene_tag
        @scenario_number+=1
        @scenario_red = false
        case(feature_element)
          when Ast::Scenario
            css_class = "scenario"
          when Ast::ScenarioOutline
            css_class = "scenario outline"
        end
        @builder << "<div class='#{css_class}'>"
        @in_scenario_outline = feature_element.class == Ast::ScenarioOutline
      end

      def after_features(feature)
        print_stats(feature)
        all_tags = @scenario_tags.flatten.uniq.sort_by {|w| w.downcase }
        @builder << "<script>"
        @builder << "$(document).ready(function () {"
        @builder << "$('center').append('<br /><div id=\"filter\"><span style=\"margin: 5px auto auto auto;\"><b>Filter Results by Tag: </b></span><select id=\"tags\" name=\"tags\"><option value=\"All\">All</option></select></div>');"
        all_tags.each do |tag|
          @builder << "$('#tags').append('<option value=\"#{tag}\" name=\"#{tag}\">#{tag}</option>');"
        end
        i = 1
        @scenario_tags.each do |set|
          tag_list = "[\""
          tag_list << set.join("\",\"")
          tag_list << "\"]"
          @builder << "$('#scenario_#{i}').parent().data('taglist', #{tag_list});"
          i = i + 1
        end

        @builder << "$('#tags').change( function () {"
        @builder << "$('.scenario').each ( function () {"
        @builder << "if($('#tags option:selected').text() === \"All\")"
        @builder << "{"
        @builder << "$(this).show();"
        @builder << "$('.feature').each( function () {"
        @builder << "$(this).show();"
        @builder << "});"
        @builder << "}"
        @builder << "else if($(this).data('taglist') && ($(this).data('taglist').indexOf($('#tags option:selected').text())) > -1)"
        @builder << "{"
        @builder << "$(this).show();"
        @builder << "}"
        @builder << "else"
        @builder << "{"
        @builder << "$(this).hide();"
        @builder << "}"
        @builder << "});"
        @builder << "$('.feature').each( function () {"
        @builder << "var tog = true;"
        @builder << "$(this).children('.scenario').each( function () {"
        @builder << "if($(this).is(':visible'))"
        @builder << "{"
        @builder << "tog = false;"
        @builder << "}"
        @builder << "});"
        @builder << "if(tog == true)"
        @builder << "{"
        @builder << "$(this).hide();"
        @builder << "}"
        @builder << "});"
        @builder << "});"
        @builder << "});"
        @builder << "</script>"

        @builder << '</div>'
        @builder << '</body>'
        @builder << '</html>'
      end

      protected

      def move_progress
        @builder << " <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
        @builder <<  "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{print_stat_string(nil)}\";</script>"
      end

    end
  end
end

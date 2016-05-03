module Cucumber
  module Formatter
    module WDSCucumberTree
      #-------------------------------------------------
      #Accessors
      #-------------------------------------------------
      def features
        @feature_hashes ||= []
      end

      def current_feature
        features[-1]
      end

      def feature_elements
        current_feature['elements'] ||= []
      end

      def current_feature_element
        feature_elements[-1]
      end

      def steps
        current_feature_element['steps'] ||= []
      end

      def current_step
        steps[-1]
      end

      def examples
        current_feature_element['examples'] ||= []
      end

      def current_example
        examples[-1]
      end

      def rows
        if @multiline_arg
          current_step['rows'] ||= []
        else
          current_example['rows'] ||= []
        end
      end

      def current_row
        rows[-1]
      end

      def cells
        current_row['cells'] ||= []
      end

      #-------------------------------------------------
      #Annotation Accessors
      #-------------------------------------------------
      def comments
        @current_hook['comments'] ||= []
      end

      def current_comment
        comments[-1]
      end

      def tags
        @current_hook['tags'] ||= []
      end

      def current_tag
        tags[-1]
      end
    end
  end
end

require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    # @private
    # Defines helper I/O methods for the formatters.
    module Io
      def ensure_io(path_or_io, _name)
        return nil if path_or_io.nil?
        return path_or_io if path_or_io.respond_to?(:write)
        file = File.open path_or_io, 'w:UTF-8' # Process in UTF-8 mode
        at_exit do
          unless file.closed?
            file.flush
            file.close
          end
        end
        file
      end
    end # Io
  end # Formatter
end # Cucumber

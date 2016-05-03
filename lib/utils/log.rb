require 'logger'
require 'singleton'

#
# Log class used by both Cucumber step definitions and the test framework.
# The test framework can use the logger like:
#
# @example Log a debug and info message
#   # Write a message to the log
#   Log.instance.debug message
#
#   # Write a message to the log and to the console
#   Log.instance.info message
#
class Log < Logger
  include Singleton
  attr_reader :timestamp, :log_file_path

  def initialize
    @level = ENV['LOG_SEVERITY'].nil? ? Logger::DEBUG : eval("Logger::#{ENV['LOG_SEVERITY']}")
    if @start_new_log
      @timestamp = Time.now.strftime('%Y_%m_%d-%HH_%MM_%SS_%LS')
      @log_file_path = "#{log_directory}/cucumber_#{@timestamp}.log"
      super(@log_file_path)
      @formatter = Formatter.new
      @datetime_format = "%Y-%m-%d %H:%M:%S.%L "
    end
  end

  def start_new(directory)
    @start_new_log = true
    @log_directory = directory
    initialize
    self
  end

  #
  # Logs a debug message to the cucumber logger (and the console if running the test from RubyM
  #
  # Logs an info message to the cucumber logger (and the console if running the test from RubyMine).
  #
  def info(message)
    if info?
      # Always log to console so info statements show up in cucumber report.
      # cucumber_world is injected into this object via the common hooks to give us access to cucumber world.
      @cucumber_world.puts(message) if @cucumber_world
      super
    end
  end

  #
  # Logs a warning message to the cucumber logger (and the console if running the test from RubyMine).
  #


  #
  # Logs an error message to the cucumber logger (and the console if running the test from RubyMine).
  #


  private

  def log_directory
    @log_directory ||= Dir.getwd
  end


end
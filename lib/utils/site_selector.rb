require_relative 'execution_environment'

#
# Provides helper methods for dealing with macys/bloomingdales differences.
#
# @example: Use the methods in the PageObject element definitions
#   class HomePage
#     include SiteSelector
#     link :sign_in, mcom_bcom({:id => 'mcom_id'}, {:id => 'bcom_id'})
#
#     def do_something
#       puts "Macys.com" if macys?
#     end
#   end
#
module SiteSelector
  # Makes the SiteSelector methods available from the class definition as well as instance methods.
  def self.included(cls)
    cls.extend self
  end

  #
  # Returns true if the site under test is a Macys environment; false otherwise.
  #
  def macys?
    ExecutionEnvironment.macys?
  end

  #
  # Returns true if the site under test is a Bloomingdales environment; false otherwise.
  #
  def bloomingdales?
    ExecutionEnvironment.bloomingdales?
  end

  #
  # Returns the first parameter if the site under test is a Macy's environment;
  # returns the second parameter if the site under test is a Bloomingdale's environment.
  #
  def mcom_bcom(macys_locator, bloomingdales_locator)
    macys? ? macys_locator : bloomingdales_locator
  end
end

DataMagic.add_translator SiteSelector
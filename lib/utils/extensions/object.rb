
class Object
  #
  # Returns true if the current object is nil or is equal to an empty string.
  #
  # @example nil and empty tests
  #   name = nil
  #   name.nil_or_empty?   # => true
  #   name = ''
  #   name.nil_or_empty?   # => true
  #   name = 'a'
  #   name.nil_or_empty?   # => false
  #
  def nil_or_empty?
    self.nil? or self == ''
  end
end
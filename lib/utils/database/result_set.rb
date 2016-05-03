module Database
  class ResultSet
    @resultset = nil
    #basing this off of jdbc result set behavior to reduce turmoil- annoyingly 0 means not set to a row, index -1 is row
    @index = 0

    def initialize(resultset)
      if (resultset == nil)
        raise 'Error - Initializing result set with nil'
      end
      @resultset = resultset
      #interesting this is necessary if you access the class before leaving the block it is newed from..
      #to me this is a bug- if I get time bug jar and send to ruby community
      @index = 0
    end

    def active_record_result_set
      @resultset
    end

    def last
      retval = true
      if @resultset.empty?
        retval = false
      end
      @index = @resultset.rows.length

      retval
    end

    def getRow
      @index
    end

    def first
      retval = true
      if @resultset.empty?
        retval = false
        @index = 0
      else
        @index = 1
      end

      retval
    end

    def getString(column_label)
      retval = nil
      if (@index != 0)
        label = column_label.downcase
        retval = @resultset[@index-1][label].to_s
      end
      retval
    end

    def next
      retval = true
      if @resultset.empty?
        retval = false
      else
        @index += 1
        if (@index > @resultset.rows.length)
          retval = false
          @index = @resultset.rows.length + 1 #just in case some jackalope calls it more than once when at the end
        end
      end
      retval
    end

    def beforeFirst
      @index = 0
    end

    def isBeforeFirst
      retval = true
      if (@resultset.empty?) || (@index != 0)
        retval = false
      end
      retval
    end

  end

end

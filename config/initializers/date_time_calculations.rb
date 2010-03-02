module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Enables the use of time calculations within Time itself
      module Calculations
        # Returns a new Time representing the start of the hour (10:00)
        def beginning_of_hour
          change(:hour => self.hour)
        end
        
        alias :at_beginning_of_hour :beginning_of_hour
      end
    end
  end
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module DateTime #:nodoc:
      # Enables the use of time calculations within DateTime itself
      module Calculations
        # Returns a new DateTime representing the start of the hour (10:00)
        def beginning_of_hour
          change(:hour => self.hour)
        end
        
        alias :at_beginning_of_hour :beginning_of_hour
      end
    end
  end
end

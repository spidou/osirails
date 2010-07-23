module ProductTest
  
  class << self
    def included base
      base.class_eval do
        
        should_validate_presence_of :name
        
      end
    end
  end
  
end

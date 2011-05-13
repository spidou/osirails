# module to gather methods used in product.rb, quote_item.rb, etc
# any model which has the following methods can implement that module :
#   - width
#   - length
#   - height

module ProductDimensions
  class << self
    def included base #:nodoc:
      base.send :include, InstanceMethods
      
      base.class_eval do
        validates_numericality_of :width, :length, :height, :allow_nil => true, :greater_than => 0
        
        validates_presence_of :width,   :if => :length
        validates_presence_of :length,  :if => :width
        
        validates_presence_of :width, :length, :if => :height
      end
    end
  end
  
  module InstanceMethods
    
    def dimensions
      @dimensions = []
      @dimensions << "#{width}" unless width.blank?
      @dimensions << "#{length}" unless length.blank?
      @dimensions << "#{height}" unless height.blank?
      @dimensions = @dimensions.join(" x ")
      @dimensions.blank? ? "" : "#{@dimensions} mm"
    end
    
    #TODO test this method
    def dimensions_was
      @dimensions_was = []
      @dimensions_was << "#{width_was}" unless width_was.blank?
      @dimensions_was << "#{length_was}" unless length_was.blank?
      @dimensions_was << "#{height_was}" unless height_was.blank?
      @dimensions_was = @dimensions_was.join(" x ")
      @dimensions_was.blank? ? "" : "#{@dimensions_was} mm"
    end
    
  end
end

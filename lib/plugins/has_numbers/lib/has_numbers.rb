module HasNumbers

  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_numbers
      
      class_eval do
        has_many :numbers, :as => :has_number
        validates_associated :numbers
        
        # this method permit to save the numbers of the employee when it is passed with the employee form
        def number_attributes=(number_attributes)
          number_attributes.each do |attributes|
            if attributes[:id].blank?
              self.numbers.build(attributes)
            else
              number = self.numbers.detect { |t| t.id == attributes[:id].to_i} 
              number.attributes = attributes
            end
          end
        end
        
        after_save :save_numbers
        
        def save_numbers
          self.numbers.each do |number|
            if number.should_destroy?    
              number.destroy    
            else
              number.save(false)
            end
          end 
        end
        
      end
      
    end
    
  end
  

end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasNumbers)
end

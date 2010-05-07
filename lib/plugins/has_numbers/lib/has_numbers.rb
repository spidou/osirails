module HasNumbers

  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_numbers
      
      class_eval do
        has_many :numbers, :as => :has_number, :dependent => :destroy
        validates_associated :numbers
        
        # this method permit to save the numbers of the employee when it is passed with the employee form
        def number_attributes=(number_attributes)
          number_attributes.each do |attributes|
            attributes.delete("#{self.class.singularized_table_name}_id")
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
    
    def has_number(key)
  
      key = key.to_sym if key.is_a?(String)

      raise ArgumentError, "[has_number] wrong key (#{key}), it is already used as a method of #{self.class.name}" if self.respond_to?(key)
      
      class_eval do
        has_one key, :class_name => 'Number', :as => :has_number, :conditions => ['has_number_key =?', key.to_s], :dependent => :destroy
        validates_associated key
        
        define_method "#{key}_attributes=" do |attributes|
          if self.send(key).nil?
            self.send("build_#{key}", attributes) unless attributes[:number].blank?
          else
            self.send(key).attributes = attributes
          end
        end
        
        define_method "build_#{key}" do |attributes|
          attributes ||= {}
          self.send("#{key}=", Number.new) unless self.send(key)                # Create a new and then build it because the build need a record to be called and the
          self.send(key).build(attributes.merge({:has_number_key => key.to_s})) #  affectation with '=' seems to add errors like with ".valid?"
        end        
                
        after_save "save_#{key}"
        
        define_method "save_#{key}" do
          number = self.send(key)
          if number
            if !number.new_record? and number.should_destroy?
              Number.find_by_id(number.id).destroy # self.send(key).destroy only remove the relationship (by nullifying has_number_id), so we remove the instance
            else
              number.save(false) if number.changed?
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

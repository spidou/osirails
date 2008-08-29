module ActiveRecord
  module Acts
    module Document
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_document

          has_many_document
          
          class_eval <<-EOV
            include ActiveRecord::Acts::Document::InstanceMethods
          EOV
        end
      end      
      
      module InstanceMethods
        def test
          puts "test"        
        end
      end 
    end
  end
end

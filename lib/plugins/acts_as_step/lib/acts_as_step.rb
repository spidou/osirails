# ActsAsStep
require 'active_record'

module ActiveRecord
  module Acts #:nodoc:
    module Step #:nodoc:
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_step
          # this is at the class level
          # add any class level manipulations you need here, like has_many, etc.
          extend ActiveRecord::Acts::Step::SingletonMethods
          include ActiveRecord::Acts::Step::InstanceMethods
          
          acts_as_file
          
          has_many :remarks
          has_many :checklist_responses
          
        end
      end
      
      # Adds SingletonMethods
      module SingletonMethods
       
      end
      
      # Adds instance methods.
      module InstanceMethods
        def parent
          Step.find_by_name(Step.find_by_name(self.name).parent.name).camelize.constantize.find_by_order_id(self.order.id)
        end
      end
      
    end
  end
end
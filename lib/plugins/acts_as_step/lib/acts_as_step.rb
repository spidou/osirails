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
          
          # Plugins
          acts_as_file
          
          # Relationships
          has_many :remarks
          has_many :checklist_responses
          has_many :missing_elements
        end
      end
      
      # Adds SingletonMethods
      module SingletonMethods
        def step
          'Step'.constantize.find_by_name(self.name.tableize.singularize)
        end
      end
      
      # Adds instance methods.
      module InstanceMethods
        def parent
          send(self.class.step.parent.name)
        end
      end
      
    end
  end
end
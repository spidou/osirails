module Journalization
  module Models
    module Actor
      class << self
        def included base #:nodoc:
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def acts_on_journalization_with identifier 
          if Journalization.const_defined?("ActorClassName") && Journalization::ActorClassName != self.name
            raise "acts_on_journalization_with cannot be called more than once" 
          else
            Journalization.const_set("ActorClassName", self.name)

            raise ArgumentError, "acts_on_journalization_with expected a symbol or a string corresponding to a method name" unless identifier.instance_of?(Symbol) || identifier.instance_of?(String)
            self.journalize :identifier_method => identifier unless (Journalization.const_defined?("SubjectsClassName") && Journalization::SubjectsClassName.include?(self.name))
            
            class_eval do
              def self.journalization_actor_object=(actor_object)
                Thread.current["#{self.to_s.downcase}_#{self.object_id}_journalization_actor_object"] = actor_object
              end
              
              def self.journalization_actor_object
                Thread.current["#{self.to_s.downcase}_#{self.object_id}_journalization_actor_object"]
              end
              
              def self.reset_journalization_actor_object
                Thread.current["#{self.to_s.downcase}_#{self.object_id}_journalization_actor_object"] = nil
              end
            end
            
            Journal.class_eval do
              belongs_to :actor, :class_name => Journalization::ActorClassName, :foreign_key => :actor_id
            end
            
          end
        end
      end
    end
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Journalization::Models::Actor)
end

module Journalization
  module Controllers
    module ActorSetting
      class << self
        def included base #:nodoc:
          base.extend ClassMethods
        end
      end
      
      module ClassMethods
        def set_journalization_actor(additional_methods = [:create, :update])
          if Journalization.const_defined?("ActorClassName")
            self.before_filter.delete(self.before_filter.detect {|f| f.method == :set_journalization_actor_object})
            self.after_filter.delete(self.after_filter.detect   {|f| f.method == :reset_journalization_actor_object})
            
            class_exec(additional_methods) do
              before_filter :set_journalization_actor_object,   :only => additional_methods
              after_filter  :reset_journalization_actor_object, :only => additional_methods
              
              def set_journalization_actor_object
                Journalization::ActorClassName.constantize.journalization_actor_object = self.current_user
              end

              def reset_journalization_actor_object
                Journalization::ActorClassName.constantize.reset_journalization_actor_object
              end
            end
          end
        end
      end
    end
  end
end

# Set it all up.
if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, Journalization::Controllers::ActorSetting)
end

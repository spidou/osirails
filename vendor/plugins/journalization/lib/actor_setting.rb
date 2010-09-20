#  journalization  Copyright (C) 2010  Ronnie Heritiana RABENANDRASANA (http://github.com/rOnnie974)
#
#  Contributor: Mathieu FONTAINE aka spidou (http://github.com/spidou)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.

module Journalization
  module Controllers
    module ActorSetting
      class << self
        def included base #:nodoc:
          base.extend ClassMethods
        end
      end
      
      module ClassMethods
        def set_journalization_actor(actions = [:create, :update])
          if Journalization.const_defined?("ActorClassName")
            self.before_filter.delete(self.before_filter.detect {|f| f.method == :set_journalization_actor_object})
            self.after_filter.delete(self.after_filter.detect   {|f| f.method == :reset_journalization_actor_object})
            
            class_exec(actions) do
              before_filter :set_journalization_actor_object,   :only => actions
              after_filter  :reset_journalization_actor_object, :only => actions
              
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

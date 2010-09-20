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

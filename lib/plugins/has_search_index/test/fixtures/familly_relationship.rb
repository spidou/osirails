class FamillyRelationship < ActiveRecord::Base
  belongs_to :person
  belongs_to :love, :class_name => 'Person'
end

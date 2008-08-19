class Content < ActiveRecord::Base
  
  # Serialize
  serialize :contributors
  
  # Relationship
  belongs_to :menu
  belongs_to :author, :class_name => "User"
  has_many :versions, :class_name => "ContentVersion"

    # Validation Macros
  validates_presence_of :title, :message => "ne peut être vide"
  
end
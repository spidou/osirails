class Content < ActiveRecord::Base
  
  # Serialize
  serialize :contributors
  
  # Relationship
  belongs_to :menu
  has_many :versions, :class_name => "ContentVersion"
  validates_presence_of :title
  
end
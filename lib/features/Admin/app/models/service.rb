class Service < ActiveRecord::Base
  
  # Relationship
  has_and_belongs_to_many :employees
  belongs_to :parent_service, :class_name =>"Service", :foreign_key => "service_parent_id"
  acts_as_tree :order => :name, :foreign_key => "service_parent_id"

end
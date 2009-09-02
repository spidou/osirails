class Job < ActiveRecord::Base
  has_permissions :as_business_object

  has_and_belongs_to_many :employees
  has_many :tools
  
  validates_uniqueness_of :name
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:activity] = "Activit&eacute;s :"
  @@form_labels[:mission] = "Missions :"
  @@form_labels[:goal] = "Objectifs :"
end  

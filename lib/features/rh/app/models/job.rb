class Job < ActiveRecord::Base
  has_permissions :as_business_object
  
  validates_uniqueness_of :name
  
  has_search_index :only_attributes => ["name"]
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:activity] = "Activit&eacute;s :"
  @@form_labels[:mission] = "Missions :"
  @@form_labels[:goal] = "Objectifs :"
end  

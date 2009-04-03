class Job < ActiveRecord::Base
  has_permissions :as_business_object

  has_and_belongs_to_many :employees
  validates_uniqueness_of :name, :message => "la fonction existe déjà!"
  @@form_labels = Hash.new
  @@form_labels[:activity] = "Activit&eacute; :"
  @@form_labels[:name] = "Nom :"
  @@form_labels[:mission] = "Missions :"
  @@form_labels[:goal] = "Objectifs :"
end  

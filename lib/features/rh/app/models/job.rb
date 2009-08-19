class Job < ActiveRecord::Base
  has_permissions :as_business_object

  has_and_belongs_to_many :employees
  validates_uniqueness_of :name
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:activity] = "Activit&eacute;s :"
  @@form_labels[:mission] = "Missions :"
  @@form_labels[:goal] = "Objectifs :"
  
  # for pagination : number of instances by index page
  JOBS_PER_PAGE = 15
end  

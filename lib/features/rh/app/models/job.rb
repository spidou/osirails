class Job < ActiveRecord::Base
  has_permissions :as_business_object
  
  # relationships
  has_many :employees_jobs, :dependent => :destroy
  has_many :employees, :through => :employees_jobs
  
  belongs_to :service
  
  # validates
  validates_uniqueness_of :name
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:service] = "Service :"
  @@form_labels[:name] = "Nom :"
  @@form_labels[:activity] = "Activit&eacute;s :"
  @@form_labels[:mission] = "Missions :"
  @@form_labels[:goal] = "Objectifs :"
  @@form_labels[:responsible] = "Responsable ? :"
end  

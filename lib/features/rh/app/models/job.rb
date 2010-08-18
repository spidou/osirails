class Job < ActiveRecord::Base
  journalize :identifier_method => :name
  
  has_permissions :as_business_object
  
  has_many :employees_jobs, :dependent => :destroy
  has_many :employees, :through => :employees_jobs
  
  belongs_to :service
  
  named_scope :with_responsibility, :conditions => ["responsible=true"]
  
  validates_uniqueness_of :name
  
  has_search_index :only_attributes => [:name]
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:service]     = "Service :"
  @@form_labels[:name]        = "Nom :"
  @@form_labels[:activity]    = "Activités :"
  @@form_labels[:mission]     = "Missions :"
  @@form_labels[:goal]        = "Objectifs :"
  @@form_labels[:responsible] = "Responsable ? :"
  
  # for pagination : number of instances by index page
  JOBS_PER_PAGE = 15
end

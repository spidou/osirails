class Job < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :employees_jobs, :dependent => :destroy
  has_many :employees, :through => :employees_jobs
  
  belongs_to :service
  
  named_scope :with_responsibility, :conditions => ["responsible = ?", true]
  
  journalize :identifier_method => :name
  
  validates_uniqueness_of :name
  
  has_search_index :only_attributes => [:id, :name, :responsible, :mission, :activity, :goal],
                   :identifier => :name
  
  # for pagination : number of instances by index page
  JOBS_PER_PAGE = 15
end

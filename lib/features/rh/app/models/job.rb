class Job < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :employees_jobs, :dependent => :destroy
  has_many :employees, :through => :employees_jobs
  
  belongs_to :service
  
  named_scope :with_responsibility, :conditions => ["responsible = ?", true]
  
  validates_uniqueness_of :name
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [:id, :name, :responsible, :mission, :activity, :goal],
                   :identifier => :name
  
  # for pagination : number of instances by index page
  JOBS_PER_PAGE = 15
  
  # return all n+1 responsibles
  def responsibles
    if self.responsible
      current_service = self.service
      responsibles    = []
      while(current_service.parent && responsibles.empty?)
        current_service = current_service.parent
        responsibles = current_service.responsibles
      end
      responsibles
    else
      self.service.responsibles
    end
  end
end

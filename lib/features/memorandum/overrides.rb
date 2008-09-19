Service.module_eval do 
  
  # Relationships
  has_many :memorandums_services
  has_many :memorandums, :through => :memorandums_services

end

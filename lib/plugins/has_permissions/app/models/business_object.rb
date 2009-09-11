class BusinessObject < ActiveRecord::Base
  setup_has_permissions_model
  
  validates_uniqueness_of :name
  
  def title
    name.titleize
  end
  
end

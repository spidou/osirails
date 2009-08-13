class BusinessObjectPermissionsPermissionMethod < ActiveRecord::Base
  belongs_to :business_object_permission
  belongs_to :permission_method
  
  validates_presence_of :business_object_permission_id, :permission_method_id
  
  def active?
    active == true
  end
end

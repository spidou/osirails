class PermissionsPermissionMethod < ActiveRecord::Base
  belongs_to :permission
  belongs_to :permission_method
  
  validates_presence_of :permission_id, :permission_method_id
  
  def active?
    active == true
  end
end

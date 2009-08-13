require_dependency 'business_object_permission' # oddly enough, without that require call, has_many business_object_permissions and
                                                # business_object_permissions_permission_methods do not work well in development environment

class PermissionMethod < ActiveRecord::Base
  has_many :business_object_permissions_permission_methods, :dependent => :destroy
  has_many :business_object_permissions, :through => :business_object_permissions_permission_methods
  
  validates_presence_of :name
end

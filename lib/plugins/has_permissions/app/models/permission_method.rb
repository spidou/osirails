require_dependency 'permission' # oddly enough, without that require call, has_many permissions 
                                # and permissions_permission_methods do not work well in development environment

class PermissionMethod < ActiveRecord::Base
  has_many :permissions_permission_methods, :dependent => :destroy
  has_many :permissions, :through => :permissions_permission_methods
  
  validates_presence_of :name
end

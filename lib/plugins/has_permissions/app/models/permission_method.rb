require_dependency 'permission' # oddly enough, without that require call, has_many permissions 
                                # and permissions_permission_methods do not work well in development environment

class PermissionMethod < ActiveRecord::Base
  has_many :permissions_permission_methods, :dependent => :destroy
  has_many :permissions, :through => :permissions_permission_methods
  
  validates_presence_of :name
  
  # return the name needed to retrieve the permission value
  #
  # permission_method = PermissionMethod.first
  # permission_method.name    # => "list"
  # permission_method.p_name  # => "list?"
  #
  # permission = Permission.first
  # permission.list    # => raise undefined_method 'list'
  # permission.list?   # => true
  #
  # permission.send(permission_method.name)   # => raise undefined_method 'list'
  # permission.send(permission_method.p_name) # => true
  # 
  def p_name
    "#{name}?"
  end
end

class BusinessObject < ActiveRecord::Base
  has_many :permissions, :class_name => "BusinessObjectPermission", :dependent => :destroy
  
  add_create_permissions_callback
end

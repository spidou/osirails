class BusinessObject < ActiveRecord::Base
  setup_has_permissions_model :association_options => { :name => :permissions, :class_name => "BusinessObjectPermission" }
end

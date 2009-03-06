class BusinessObjectPermission < ActiveRecord::Base
  belongs_to :business_object
  belongs_to :role
end

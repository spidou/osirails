class BusinessObjectPermission < ActiveRecord::Base
  belongs_to :has_permission, :polymorphic => true
  belongs_to :role
end
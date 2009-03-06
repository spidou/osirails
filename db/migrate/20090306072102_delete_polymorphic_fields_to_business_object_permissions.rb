class DeletePolymorphicFieldsToBusinessObjectPermissions < ActiveRecord::Migration
  def self.up
    remove_columns :business_object_permissions, :has_permission_type, :has_permission_id
    add_column :business_object_permissions, :business_object_id, :integer
  end

  def self.down
    add_column :business_object_permissions, :has_permission_type, :string
    add_column :business_object_permissions, :has_permission_id, :integer
    remove_column :business_object_permissions, :business_object_id
  end
end

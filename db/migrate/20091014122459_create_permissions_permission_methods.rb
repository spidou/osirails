class CreatePermissionsPermissionMethods < ActiveRecord::Migration
  def self.up
    create_table :permissions_permission_methods do |t|
      t.references :permission, :permission_method
      t.boolean    :active
      
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions_permission_methods
  end
end

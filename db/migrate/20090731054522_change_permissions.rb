class ChangePermissions < ActiveRecord::Migration
  def self.up
    remove_column :business_object_permissions, :list
    remove_column :business_object_permissions, :view
    remove_column :business_object_permissions, :add
    remove_column :business_object_permissions, :edit
    remove_column :business_object_permissions, :delete
    
    create_table :permission_methods do |t|
      t.string :name
      t.string :title
    end
    
    create_table :business_object_permissions_permission_methods do |t|
      t.references :business_object_permission, :permission_method
      t.boolean :active
    end
  end

  def self.down
    add_column :business_object_permissions, :list,   :boolean
    add_column :business_object_permissions, :view,   :boolean
    add_column :business_object_permissions, :add,    :boolean
    add_column :business_object_permissions, :edit,   :boolean
    add_column :business_object_permissions, :delete, :boolean
    
    drop_table :permission_methods
    
    drop_table :business_object_permissions_permission_methods
  end
end

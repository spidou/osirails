class PermissionPolymorphism < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.references  :role
      t.string      :has_permissions_type
      t.integer     :has_permissions_id
      
      t.timestamps
    end
    
    create_table :permissions_permission_methods do |t|
      t.references :permission, :permission_method
      t.boolean    :active
      
      t.timestamps
    end
    
    drop_table :business_object_permissions_permission_methods
    
    drop_table :business_object_permissions
    drop_table :menu_permissions
    drop_table :document_type_permissions
    drop_table :calendar_permissions
  end

  def self.down
    drop_table :permissions
    drop_table :permissions_permission_methods
    
    create_table :business_object_permissions_permission_methods do |t|
      t.references :business_object_permission, :permission_method
      t.boolean    :active
    end
    
    create_table :business_object_permissions do |t|
      t.references :role, :business_object
      t.timestamps
    end
    
    create_table :menu_permissions do |t|
      t.references :role, :menu
      t.boolean  :list
      t.boolean  :view
      t.boolean  :add
      t.boolean  :edit
      t.boolean  :delete
      
      t.timestamps
    end
    
    create_table :document_type_permissions do |t|
      t.references :role, :document_type
      t.boolean  :list
      t.boolean  :view
      t.boolean  :add
      t.boolean  :edit
      t.boolean  :delete
      
      t.timestamps
    end
    
    create_table :calendar_permissions do |t|
      t.references :role, :calendar
      t.boolean  :list
      t.boolean  :view
      t.boolean  :add
      t.boolean  :edit
      t.boolean  :delete
      
      t.timestamps
    end
  end
end

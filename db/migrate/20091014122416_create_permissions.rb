class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.references  :role
      t.string      :has_permissions_type
      t.integer     :has_permissions_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end

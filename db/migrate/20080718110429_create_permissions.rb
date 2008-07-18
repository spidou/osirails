class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.boolean :list, :view, :add, :edit, :delete
      t.references :role
      t.string :has_permission_type
      t.integer :has_permission_id
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end

class CreatePagePermissions < ActiveRecord::Migration
  def self.up
    create_table :page_permissions do |t|
      t.boolean :list, :view, :add, :edit, :delete
      t.references :role, :page
      t.timestamps
    end
  end

  def self.down
    drop_table :page_permissions
  end
end

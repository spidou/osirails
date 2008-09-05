class CreateCalendarPermissions < ActiveRecord::Migration
  def self.up
    create_table :calendar_permissions do |t|
      t.boolean :list, :view, :add, :edit, :delete
      t.references :role, :calendar
      
      t.timestamps
    end
  end

  def self.down
    drop_table :calendar_permissions
  end
end

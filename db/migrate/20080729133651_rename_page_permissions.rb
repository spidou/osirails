class RenamePagePermissions < ActiveRecord::Migration
  def self.up
    rename_table(:page_permissions, :menu_permissions)
  end

  def self.down
    rename_table(:menu_permissions, :page_permissions)
  end
end

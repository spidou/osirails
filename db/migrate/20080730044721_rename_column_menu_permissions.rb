class RenameColumnMenuPermissions < ActiveRecord::Migration
  def self.up
    rename_column(:menu_permissions, :page_id, :menu_id)
  end

  def self.down
    rename_column(:menu_permissions, :menu_id, :page_id)
  end
end

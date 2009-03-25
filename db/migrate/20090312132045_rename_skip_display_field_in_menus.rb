class RenameSkipDisplayFieldInMenus < ActiveRecord::Migration
  def self.up
    rename_column :menus, :skip_display, :hidden
  end

  def self.down
    rename_column :menus, :hidden, :skip_display
  end
end

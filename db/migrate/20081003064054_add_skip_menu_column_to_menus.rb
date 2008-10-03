class AddSkipMenuColumnToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :skip_display, :boolean, :default => false
  end

  def self.down
    remove_column :menus, :skip_display
  end
end

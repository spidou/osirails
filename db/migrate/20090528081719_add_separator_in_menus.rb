class AddSeparatorInMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :separator, :string
  end

  def self.down
    remove_column :menus, :separator
  end
end

class RemoveUrlFromMenus < ActiveRecord::Migration
  def self.up
    remove_column :menus, :url
  end

  def self.down
    add_column :menus, :url, :string
  end
end

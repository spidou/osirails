class AddFeatureIdInMenu < ActiveRecord::Migration
  def self.up
    add_column :menus, :feature_id, :integer
  end

  def self.down
    remove_column :menus, :feature_id
  end
end

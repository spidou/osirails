class AddColumnFeatures < ActiveRecord::Migration
  def self.up
    add_column :features, :title, :string
  end

  def self.down
    remove_column :features, :title
  end
end

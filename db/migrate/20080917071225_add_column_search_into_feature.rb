class AddColumnSearchIntoFeature < ActiveRecord::Migration
  def self.up
    add_column :features, :search, :text
  end

  def self.down
    remove_column :features, :search
  end
end

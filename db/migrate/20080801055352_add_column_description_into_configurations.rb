class AddColumnDescriptionIntoConfigurations < ActiveRecord::Migration
  def self.up
    add_column :configurations, :description, :string
  end

  def self.down
    remove_column :configurations, :description
  end
end

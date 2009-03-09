class RemoveBusinessObjectFieldInFeatures < ActiveRecord::Migration
  def self.up
    remove_column :features, :business_objects
  end

  def self.down
    add_column :features, :business_objects, :text
  end
end

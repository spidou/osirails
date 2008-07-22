class AddBusinessObjectToFeature < ActiveRecord::Migration
  def self.up
    add_column :features , :business_objects , :text 
  end

  def self.down
    remove_column :features , :business_objects
  end
end

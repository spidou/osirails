class CreateBusinessObjects < ActiveRecord::Migration
  def self.up
    create_table :business_objects do |t|
      t.string :name
    end
    
    add_index :business_objects, :name, :unique => true
  end

  def self.down
    drop_table :business_objects
  end
end

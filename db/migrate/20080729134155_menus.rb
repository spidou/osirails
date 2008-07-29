class Menus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.string :title, :description, :url
      t.string :name, :default => nil
      t.integer :position, :parent_id 
      
      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end

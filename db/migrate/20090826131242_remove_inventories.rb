class RemoveInventories < ActiveRecord::Migration
  def self.up
    drop_table :inventories 
  end

  def self.down
    create_table :inventories do |t|
      t.boolean :closed, :default => false
      t.timestamps
    end
  end
end

class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.integer :lock_version, :default => 0, :null => false
      t.boolean :closed, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :inventories
  end
end

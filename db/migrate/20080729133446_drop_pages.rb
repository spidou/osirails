class DropPages < ActiveRecord::Migration
  def self.up
    drop_table :pages
  end

  def self.down
    create_table :pages do |t|
      t.string :title_link, :description_link, :url, :type
      t.string :name, :default => nil
      t.integer :position, :parent_id 
      
      t.timestamps
    end
  end
end

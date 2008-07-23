class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title_link, :description_link, :url, :type
      t.string :name, :default => nil
      t.integer :position, :parent_id 
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end

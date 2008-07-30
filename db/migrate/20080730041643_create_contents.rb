class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.string :title, :description
      t.text :text
      t.integer :menu_id 
      t.string :author, :contributors
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end

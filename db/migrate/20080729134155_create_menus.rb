class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.references :parent, :feature
      t.string  :name, :title, :description, :separator
      t.integer :position
      t.boolean :hidden
      
      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end

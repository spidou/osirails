class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.references :user
      t.string  :name
      t.integer :col, :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :widgets
  end
end

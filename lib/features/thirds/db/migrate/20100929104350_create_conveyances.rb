class CreateConveyances < ActiveRecord::Migration
  def self.up
    create_table :conveyances do |t|
      t.string      :name
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :conveyances
  end
end

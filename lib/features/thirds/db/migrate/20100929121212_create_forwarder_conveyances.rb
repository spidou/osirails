class CreateForwarderConveyances < ActiveRecord::Migration
  def self.up
    create_table :forwarder_conveyances do |t|
      t.references  :forwarder, :conveyance
      
      t.timestamps
    end
    
    add_index :forwarder_conveyances, [:forwarder_id, :conveyance_id], :unique => true
  end
  
  def self.down
    drop_table :forwarder_conveyances
  end
end

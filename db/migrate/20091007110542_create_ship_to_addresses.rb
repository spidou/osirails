class CreateShipToAddresses < ActiveRecord::Migration
  def self.up
    create_table :ship_to_addresses do |t|
      t.references :order, :establishment
      t.string :establishment_name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :ship_to_addresses
  end
end

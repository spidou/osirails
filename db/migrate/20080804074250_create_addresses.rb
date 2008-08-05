class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :address1
      t.string :address2
      t.references :city
      t.references :country
      t.references :has_address, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end

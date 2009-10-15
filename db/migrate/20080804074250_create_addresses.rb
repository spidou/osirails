class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.references :has_address, :polymorphic => true
      t.string  :has_address_key
      t.text    :street_name
      t.string  :country_name, :city_name, :zip_code
      
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end

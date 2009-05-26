class RenameAddressToStreetNameInAddresses < ActiveRecord::Migration
  def self.up
    rename_column :addresses, :address, :street_name
  end

  def self.down
    rename_column :addresses, :street_name, :address
  end
end

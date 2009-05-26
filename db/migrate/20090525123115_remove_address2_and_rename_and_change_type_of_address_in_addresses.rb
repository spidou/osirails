class RemoveAddress2AndRenameAndChangeTypeOfAddressInAddresses < ActiveRecord::Migration
  def self.up
    remove_column :addresses, :address2
    rename_column :addresses, :address1, :address
    change_column :addresses, :address, :text
    add_column :addresses, :has_address_key, :string
  end

  def self.down
    add_column :addresses, :address2, :string
    rename_column :addresses, :address, :address1
    change_column :addresses, :address1, :string
    remove_column :addresses, :has_address_key
  end
end

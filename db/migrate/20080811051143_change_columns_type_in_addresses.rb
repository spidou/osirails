class ChangeColumnsTypeInAddresses < ActiveRecord::Migration
  def self.up
    remove_column :addresses, :country_id
    remove_column :addresses, :city_id
    add_column :addresses, :country_name, :string
    add_column :addresses, :city_name, :string
  end

  def self.down
   remove_column :addresses, :country_name
   remove_column :addresses, :city_name
   add_column :addresses, :country_id, :integer
    add_column :addresses, :city_id, :integer
  end
end

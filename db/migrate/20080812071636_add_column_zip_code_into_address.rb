class AddColumnZipCodeIntoAddress < ActiveRecord::Migration
  def self.up
     add_column :addresses, :zip_code, :string 
  end

  def self.down
    remove_column  :addresses, :zip_code
  end
end

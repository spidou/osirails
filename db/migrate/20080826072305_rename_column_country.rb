class RenameColumnCountry < ActiveRecord::Migration
  def self.up
    remove_column :indicatives ,:country
    add_column :indicatives ,:country_id ,:integer
  end

  def self.down
    remove_column :indicatives ,:country_id
    add_column :indicatives ,:country ,:string
  end
end

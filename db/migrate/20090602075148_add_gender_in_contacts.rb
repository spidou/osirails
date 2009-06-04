class AddGenderInContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :gender, :string
  end

  def self.down
    remove_column :contacts, :gender
  end
end

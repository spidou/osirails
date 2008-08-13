class ChangeContactsToPolymorphicTable < ActiveRecord::Migration
  def self.up
    add_column :contacts, :has_contact_type, :string
    add_column :contacts, :has_contact_id, :integer
  end

  def self.down
    remove_column :contacts, :has_contact_type
    remove_column :contacts, :has_contact_id
  end
end

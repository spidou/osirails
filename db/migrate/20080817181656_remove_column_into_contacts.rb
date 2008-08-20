class RemoveColumnIntoContacts < ActiveRecord::Migration
  def self.up
     remove_column :contacts, :has_contact_type
     remove_column :contacts, :has_contact_id
  end

  def self.down
    add_column :contacts, :has_contact_type, :string
    add_column :contacts, :has_contact_id, :integer
  end
end
class AddColumnIntoContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :type
    add_column :contacts, :contact_type_id, :integer    
  end

  def self.down
    remove_column :contacts, :contact_type_id
    add_column :contacts, :type, :integer    
  end
end
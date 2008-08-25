class AddColumnJobAndEmailIntoContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :job, :string
    add_column :contacts, :email, :string
  end

  def self.down
    remove_column :contacts, :job
    remove_column :contacts, :email
  end
end

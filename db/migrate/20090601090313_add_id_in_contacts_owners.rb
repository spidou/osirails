class AddIdInContactsOwners < ActiveRecord::Migration
  def self.up
    # in contact model => the method 'has_many' with option ':dependent' absolutely needs a primary key 'id'
    add_column :contacts_owners, :id, :integer
  end

  def self.down
    remove_column :contacts_owners, :id
  end
end

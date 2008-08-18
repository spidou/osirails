class CreateContactsOwners < ActiveRecord::Migration
  def self.up
    create_table :contacts_owners, :id => false do |t|
      t.integer :contact_id
      t.references :has_contact, :polymorphic => true
      t.integer :contact_type_id
    end
  end

  def self.down
    drop_table :contacts_owners
  end
end

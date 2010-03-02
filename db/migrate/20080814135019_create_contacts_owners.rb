class CreateContactsOwners < ActiveRecord::Migration
  def self.up
    create_table :contacts_owners do |t|
      t.references :has_contact, :polymorphic => true
      t.references :contact, :contact_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contacts_owners
  end
end

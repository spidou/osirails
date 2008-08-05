class CreateContactNumbers < ActiveRecord::Migration
  def self.up
    create_table :contact_numbers do |t|
      t.string :category
      t.string :indicatif
      t.string :number
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_numbers
  end
end

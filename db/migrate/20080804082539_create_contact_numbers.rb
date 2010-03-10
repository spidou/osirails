class CreateContactNumbers < ActiveRecord::Migration
  def self.up
    create_table :contact_numbers do |t|
      t.string :category, :indicatif, :number
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_numbers
  end
end

class CreateThirds < ActiveRecord::Migration
  def self.up
    create_table :thirds do |t|
      # common attributes
      t.references :legal_form, :activity_sector
      t.string  :type, :name, :siret_number, :activities, :website
      t.integer :note, :default => 0
      t.boolean :activated, :default => true
      
      # customer attributes
      t.references :payment_method, :payment_time_limit, :factor
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :thirds
  end
end

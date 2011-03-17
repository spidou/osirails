class CreatePaymentMethods < ActiveRecord::Migration
  def self.up
    create_table :payment_methods do |t|
      t.string :name
      
      t.timestamps
    end
    
    add_index :payment_methods, :name, :unique => true
  end

  def self.down
    drop_table :payment_methods
  end
end

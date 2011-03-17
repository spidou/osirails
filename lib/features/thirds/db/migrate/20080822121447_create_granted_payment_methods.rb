class CreateGrantedPaymentMethods < ActiveRecord::Migration
  def self.up
    create_table :granted_payment_methods do |t|
      t.string :name
      
      t.timestamps
    end
    
    add_index :granted_payment_methods, :name, :unique => true
  end

  def self.down
    drop_table :granted_payment_methods
  end
end

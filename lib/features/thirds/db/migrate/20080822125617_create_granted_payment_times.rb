class CreateGrantedPaymentTimes < ActiveRecord::Migration
  def self.up
    create_table :granted_payment_times do |t|
      t.string :name
      
      t.timestamps
    end
    
    add_index :granted_payment_times, :name, :unique => true
  end

  def self.down
    drop_table :granted_payment_times
  end
end

class CreatePaymentTimeLimits < ActiveRecord::Migration
  def self.up
    create_table :payment_time_limits do |t|
      t.string :name

      t.timestamps
    end
    
    PaymentTimeLimit.create :name => "Comptant"
    PaymentTimeLimit.create :name => "30 jours nets"
    PaymentTimeLimit.create :name => "60 jours nets"
    
  end

  def self.down
    drop_table :payment_time_limits
  end
end

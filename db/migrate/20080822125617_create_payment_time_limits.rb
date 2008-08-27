class CreatePaymentTimeLimits < ActiveRecord::Migration
  def self.up
    create_table :payment_time_limits do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_time_limits
  end
end

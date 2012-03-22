class UpdateQuotesAddGrantedPaymentTimeAndGrantedPaymentMethod < ActiveRecord::Migration
  def self.up
    add_column :quotes, :granted_payment_time_id, :integer
    add_column :quotes, :granted_payment_method_id, :integer
  end

  def self.down
    remove_column :quotes, :granted_payment_time_id
    remove_column :quotes, :granted_payment_method_id
  end
end

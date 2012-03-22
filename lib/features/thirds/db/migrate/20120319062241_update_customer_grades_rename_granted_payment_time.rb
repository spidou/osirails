class UpdateCustomerGradesRenameGrantedPaymentTime < ActiveRecord::Migration
  def self.up
    rename_column :customer_grades, :granted_payment_time_id, :granted_payment_method_id
  end

  def self.down
    rename_column :customer_grades, :granted_payment_method_id, :granted_payment_time_id
  end
end

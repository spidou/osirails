class CreateCustomerSolvencies < ActiveRecord::Migration
  def self.up
    create_table :customer_solvencies do |t|
      t.references :granted_payment_method
      t.string     :name
    end
  end

  def self.down
    drop_table :customer_solvencies
  end
end

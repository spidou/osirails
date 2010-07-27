class CreateCustomerGrades < ActiveRecord::Migration
  def self.up
    create_table :customer_grades do |t|
      t.references :payment_time_limit
      t.string     :name
    end
  end

  def self.down
    drop_table :customer_grades
  end
end

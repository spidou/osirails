class CreateCustomerGrades < ActiveRecord::Migration
  def self.up
    create_table :customer_grades do |t|
      t.string     :name
      t.references :payment_time_limit
    end
  end

  def self.down
    drop_table :customer_grades
  end
end

class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.references :due_date, :payment_method
      t.date    :paid_on
      t.float   :amount
      t.string  :bank_name
      t.string  :payment_identifier
      t.string  :attachment_file_name, :attachment_content_type
      t.integer :attachment_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end

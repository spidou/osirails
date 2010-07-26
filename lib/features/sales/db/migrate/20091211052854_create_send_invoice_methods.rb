class CreateSendInvoiceMethods < ActiveRecord::Migration
  def self.up
    create_table :send_invoice_methods do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :send_invoice_methods
  end
end

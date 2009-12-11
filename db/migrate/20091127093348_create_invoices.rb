class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.references :order, :invoice_type, :send_invoice_method, :cancelled_by, :abandoned_by
      t.string    :reference, :status
      t.boolean   :factorised
      t.text      :cancelled_comment, :abandoned_comment
      t.date      :sended_on, :abandoned_on, :factoring_recovered_on
      t.datetime  :confirmed_at, :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end

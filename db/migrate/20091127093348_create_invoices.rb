class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.references :order, :factor, :invoice_type, :send_invoice_method, :creator, :cancelled_by, :abandoned_by
      t.string    :reference, :status
      t.text      :cancelled_comment, :abandoned_comment, :factoring_recovered_comment
      t.date      :published_on, :sended_on, :abandoned_on, :factoring_recovered_on, :factoring_balance_paid_on
      t.datetime  :confirmed_at, :cancelled_at
      
      # only for deposit invoices
      t.float     :deposit, :deposit_amount, :deposit_vat
      t.text      :deposit_comment
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end

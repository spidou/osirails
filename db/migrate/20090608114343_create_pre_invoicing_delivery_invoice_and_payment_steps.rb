class CreatePreInvoicingDeliveryInvoiceAndPaymentSteps < ActiveRecord::Migration
  def self.up
    create_table :pre_invoicing_steps do |t|
      t.references :order
      t.string :status
      t.datetime :started_at
      t.datetime :finished_at
      
      t.timestamps
    end
    
    create_table :delivery_steps do |t|
      t.references :pre_invoicing_step
      t.string :status
      t.datetime :started_at
      t.datetime :finished_at
      
      t.timestamps
    end
    
    create_table :invoice_steps do |t|
      t.references :invoicing_step
      t.string :status
      t.datetime :started_at
      t.datetime :finished_at
      
      t.timestamps
    end
    
    create_table :payment_steps do |t|
      t.references :invoicing_step
      t.string :status
      t.datetime :started_at
      t.datetime :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pre_invoicing_steps
    drop_table :delivery_steps
    drop_table :invoice_steps
    drop_table :payment_steps
  end
end

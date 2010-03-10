class CreateInvoiceSteps < ActiveRecord::Migration
  def self.up
    create_table :invoice_steps do |t|
      t.references :invoicing_step
      t.string    :status
      t.datetime  :started_at
      t.datetime  :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_steps
  end
end

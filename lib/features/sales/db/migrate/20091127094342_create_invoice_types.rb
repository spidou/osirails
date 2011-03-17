class CreateInvoiceTypes < ActiveRecord::Migration
  def self.up
    create_table :invoice_types do |t|
      t.string  :name, :title
      t.boolean :factorisable, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_types
  end
end

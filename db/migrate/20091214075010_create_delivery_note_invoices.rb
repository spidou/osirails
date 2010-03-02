class CreateDeliveryNoteInvoices < ActiveRecord::Migration
  def self.up
    create_table :delivery_note_invoices do |t|
      t.references :delivery_note, :invoice
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_note_invoices
  end
end

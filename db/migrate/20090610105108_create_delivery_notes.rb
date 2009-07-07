class CreateDeliveryNotes < ActiveRecord::Migration
  def self.up
    create_table :delivery_notes do |t|
      t.references :delivery_step
      t.boolean    :on_site
      t.datetime   :signed_at
      t.datetime   :scheduled_delivery_at
      t.timestamps
    end
    
    create_table :delivery_notes_quotes_product_references do |t|
      t.references :delivery_note, :quotes_product_reference, :report_type
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_notes
    drop_table :delivery_notes_quotes_product_references
  end
end

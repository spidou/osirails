class CreateDeliveryNoteItems < ActiveRecord::Migration
  def self.up
    create_table :delivery_note_items do |t|
      t.references :delivery_note, :end_product
      t.integer :quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_note_items
  end
end

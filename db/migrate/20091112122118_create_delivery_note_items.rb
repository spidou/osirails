class CreateDeliveryNoteItems < ActiveRecord::Migration
  def self.up
    create_table :delivery_note_items do |t|
      t.references :delivery_note, :quote_item
      t.integer    :quantity, :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_note_items
  end
end

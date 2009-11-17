class CreateDiscards < ActiveRecord::Migration
  def self.up
    create_table :discards do |t|
      t.references :delivery_note_item, :discard_type
      t.text       :comments
      t.integer    :quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :discards
  end
end

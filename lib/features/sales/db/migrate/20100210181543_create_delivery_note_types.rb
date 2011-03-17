class CreateDeliveryNoteTypes < ActiveRecord::Migration
  def self.up
    create_table :delivery_note_types do |t|
      t.string :title
      t.boolean :delivery, :installation, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_note_types
  end
end

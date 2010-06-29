class CreateDiscards < ActiveRecord::Migration
  def self.up
    create_table :discards do |t|
      t.references :delivery_note_item, :delivery_intervention
      t.integer    :quantity
      t.text       :comments
      
      t.timestamps
    end
    
    add_index :discards, [:delivery_note_item_id, :delivery_intervention_id], :unique => true, :name => :index_discards_on_delivery_note_item_and_delivery_intervention
  end

  def self.down
    drop_table :discards
  end
end

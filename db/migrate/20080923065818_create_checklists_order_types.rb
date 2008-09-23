class CreateChecklistsOrderTypes < ActiveRecord::Migration
  def self.up
    create_table :checklists_order_types do |t|
      t.references :checklist
      t.references :order_type
      t.boolean :activated, :default => true
      
      t.timestamps
      end
  end

  def self.down
    drop_table :checklists_order_types
  end
end

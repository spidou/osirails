class CreateChecklistOptionsOrderTypes < ActiveRecord::Migration
  def self.up
    create_table :checklist_options_order_types do |t|
      t.references :checklist_option, :order_type
      t.boolean :activated, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_options_order_types
  end
end

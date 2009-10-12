class CreateChecklistOptions < ActiveRecord::Migration
  def self.up
    create_table :checklist_options do |t|
      t.references :checklist, :parent
      t.integer :position
      t.string  :title, :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_options
  end
end

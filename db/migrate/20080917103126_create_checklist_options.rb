class CreateChecklistOptions < ActiveRecord::Migration
  def self.up
    create_table :checklist_options do |t|
      t.string :name
      t.references :checklist
      
      t.timestamps
    end
  end

  def self.down
    drop_table:checklist_options
  end
end

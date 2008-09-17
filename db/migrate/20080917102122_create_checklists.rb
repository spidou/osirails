class CreateChecklists < ActiveRecord::Migration
  def self.up
    create_table :checklists do |t|
      t.string :name
      t.references :step
      
      t.timestamps
    end
  end

  def self.down
    drop_table :checklists
  end
end

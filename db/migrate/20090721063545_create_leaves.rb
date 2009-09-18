class CreateLeaves < ActiveRecord::Migration
  def self.up
    create_table :leaves do |t|
      t.references :employee
      t.date :start_date
      t.date :end_date
      t.boolean :start_half
      t.boolean :end_half
      t.boolean :cancelled
      t.float :retrieval
      t.timestamps
    end
  end

  def self.down
    drop_table :leaves
  end
end

class CreateLeaves < ActiveRecord::Migration
  def self.up
    create_table :leaves do |t|
      t.references :employee, :leave_type, :leave_request
      t.date    :start_date, :end_date
      t.boolean :start_half, :end_half, :cancelled
      t.float   :duration
      
      t.timestamps
    end
  end

  def self.down
    drop_table :leaves
  end
end

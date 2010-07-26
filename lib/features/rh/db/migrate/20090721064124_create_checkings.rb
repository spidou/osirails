class CreateCheckings < ActiveRecord::Migration
  def self.up
    create_table :checkings do |t|
      t.references :user, :employee
      t.date    :date
      t.integer :absence_hours, :absence_minutes, :overtime_hours, :overtime_minutes
      t.text    :absence_comment, :overtime_comment
      t.boolean :cancelled
      
      t.timestamps
    end
    
    #execute "ALTER TABLE checkings ADD CONSTRAINT date_employee_id_key UNIQUE (date, employee_id);"
  end

  def self.down
    drop_table :checkings
  end
end

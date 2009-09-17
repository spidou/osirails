class CreateTableLeaveRequests < ActiveRecord::Migration
  def self.up
    create_table :leave_requests do |t|     
      t.integer :status, :leave_type_id, :cancelled_by
      t.date :start_date, :end_date
      t.datetime :checked_at, :noticed_at, :ended_at, :cancelled_at
      t.boolean :start_half, :end_half, :responsible_agreement, :director_agreement
      t.text :comment, :responsible_remarks, :observer_remarks, :director_remarks
      t.float :acquired_leaves_days
      t.references :employee, :responsible, :observer, :director
      t.timestamps
    end
  end

  def self.down
    drop_table :leave_requests
  end
end

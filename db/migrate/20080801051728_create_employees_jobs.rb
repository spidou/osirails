class CreateEmployeesJobs < ActiveRecord::Migration
  def self.up
    create_table :employees_jobs do |t|
      t.integer :job_id, :employee_id
      t.timestamps
    end
  end

  def self.down
    drop_table :employees_jobs
  end
end

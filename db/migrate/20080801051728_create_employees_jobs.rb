class CreateEmployeesJobs < ActiveRecord::Migration
  def self.up
    create_table :employees_jobs, :id => false do |t|
      t.references :job, :employee
      t.timestamps
    end
  end

  def self.down
    drop_table :employees_jobs
  end
end

class CreateSalesProcessesSteps < ActiveRecord::Migration
  def self.up
    create_table :sales_processes_steps do |t|
      t.references :sales_process, :step
    end
  end

  def self.down
   drop_table :sales_processes_steps
  end
end

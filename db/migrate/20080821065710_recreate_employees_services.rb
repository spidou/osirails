class RecreateEmployeesServices < ActiveRecord::Migration
  def self.up
    drop_table :employees_services
    create_table :employees_services do |t|
      t.integer :employee_id, :service_id
      t.boolean :responsable, :default => false
      
      t.timestamps
    end
  end


  def self.down
    drop_table :employees_services
    create_table :employees_services, :id => false do |t|
      t.integer :employee_id, :service_id
      t.boolean :responsable, :default => false
      
      t.timestamps
    end
  end
end

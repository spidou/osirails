class AddColumnIdIntoEmployeesServices < ActiveRecord::Migration
  def self.up
    add_column :employees_services, :id, :integer
    create_table :employees_services do |t|
      t.integer :employee_id, :service_id
      t.boolean :responsable, :default => false
      
      t.timestamps
      end
  end

  def self.down
    remove_column :employees_services, :id
  end
end

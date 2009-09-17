class DropTableEmployeesServices < ActiveRecord::Migration
  def self.up
    drop_table :employees_services
  end

  def self.down
    create_table :employees_services, :force => true do |t|
      t.integer  :employee_id, :limit => 11
      t.integer  :service_id,  :limit => 11
      t.boolean  :responsable,               :default => false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end

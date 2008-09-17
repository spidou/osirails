class CreateSalesProcesses < ActiveRecord::Migration
  def self.up
    create_table :sales_processes do |t|
      t.references :order_type, :step
      #FIXME See for all boolean there default value and null value
      t.boolean :activated, :default => true
      t.boolean :depending_previous, :default => false
      t.boolean :required, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sales_processes
  end
end

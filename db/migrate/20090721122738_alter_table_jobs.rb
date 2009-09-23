class AlterTableJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :service_id, :integer
    add_column :jobs, :responsible, :boolean 
  end

  def self.down
    remove_column :jobs, :service_id
    remove_column :jobs, :responsible
  end
end

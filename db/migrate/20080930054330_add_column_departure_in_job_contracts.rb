class AddColumnDepartureInJobContracts < ActiveRecord::Migration
  def self.up
    add_column :job_contracts, :departure , :date
  end

  def self.down
    remove_column :job_contracts, :departure
  end
end

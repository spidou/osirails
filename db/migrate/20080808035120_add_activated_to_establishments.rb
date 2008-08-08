class AddActivatedToEstablishments < ActiveRecord::Migration
  def self.up
    add_column :establishments, :activated, :bool 
  end

  def self.down
    remove_column :establishments, :activated
  end
end

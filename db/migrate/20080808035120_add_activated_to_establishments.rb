class AddActivatedToEstablishments < ActiveRecord::Migration
  def self.up
    add_column :establishments, :activated, :bool, :default => true
  end

  def self.down
    remove_column :establishments, :activated
  end
end

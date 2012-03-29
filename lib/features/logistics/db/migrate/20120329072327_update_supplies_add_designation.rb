class UpdateSuppliesAddDesignation < ActiveRecord::Migration
  def self.up
    add_column :supplies, :designation, :string
  end

  def self.down
    remove_column :supplies, :designation
  end
end

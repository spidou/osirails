class AddColumnIntoEstablishment < ActiveRecord::Migration
  def self.up
    add_column :establishments, :customer_id, :integer
  end

  def self.down
    remove_column :establishments, :customer_id
  end
end

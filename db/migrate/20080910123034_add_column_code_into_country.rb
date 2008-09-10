class AddColumnCodeIntoCountry < ActiveRecord::Migration
  def self.up
    add_column :countries, :code, :string
  end

  def self.down
    remove_column :countries, :code
  end
end

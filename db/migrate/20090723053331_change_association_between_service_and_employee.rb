class ChangeAssociationBetweenServiceAndEmployee < ActiveRecord::Migration
  def self.up
    add_column :employees, :service_id, :integer 
  end

  def self.down
    remove_column :employees, :service_id
  end
end

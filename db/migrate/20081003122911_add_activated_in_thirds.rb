class AddActivatedInThirds < ActiveRecord::Migration
  def self.up
    add_column :thirds, :activated, :boolean
  end

  def self.down
    remove_column :thirds, :activated
  end
end

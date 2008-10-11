class AddActivatedInThirds < ActiveRecord::Migration
  def self.up
    add_column :thirds, :activated, :boolean, :default => true
  end

  def self.down
    remove_column :thirds, :activated
  end
end
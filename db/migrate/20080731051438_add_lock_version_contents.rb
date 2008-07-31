class AddLockVersionContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :lock_version, :integer, { :default => 0 }
  end

  def self.down
    remove_column :contents, :lock_version
  end
end

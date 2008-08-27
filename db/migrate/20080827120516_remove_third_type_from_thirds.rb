class RemoveThirdTypeFromThirds < ActiveRecord::Migration
  def self.up
    remove_column :thirds, :third_type_id
  end

  def self.down
    add_column :thirds, :third_type_id, :integer
  end
end

class ChangeWordingToNameIntoThirdType < ActiveRecord::Migration
  def self.up
    remove_column :third_types, :wording
    add_column :third_types, :name, :string
  end

  def self.down
    remove_column :third_types, :name
    add_column :third_types, :wording, :string
  end
end

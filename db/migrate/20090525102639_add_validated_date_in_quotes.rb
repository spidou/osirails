class AddValidatedDateInQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :validated_at, :datetime
  end

  def self.down
    remove_column :quotes, :validated_at
  end
end

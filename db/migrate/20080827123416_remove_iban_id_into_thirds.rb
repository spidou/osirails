class RemoveIbanIdIntoThirds < ActiveRecord::Migration
  def self.up
    remove_column :thirds, :iban_id
  end

  def self.down
    add_column :thirds, :iban_id, :integer
  end
end

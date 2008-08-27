class RenameWordingToNameIntoEstablishmentTypes < ActiveRecord::Migration
  def self.up
    remove_column :establishment_types, :wording
    add_column :establishment_types, :name, :string
  end

  def self.down
    remove_column :establishment_types, :name
    add_column :establishment_types, :wording, :string
  end
end

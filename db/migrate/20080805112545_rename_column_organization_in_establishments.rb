class RenameColumnOrganizationInEstablishments < ActiveRecord::Migration
  def self.up
    rename_column(:establishments, :organization_type_id, :establishment_type_id)
  end

  def self.down
    rename_column(:establishments, :establishment_type_id, :organization_type_id)
  end
end

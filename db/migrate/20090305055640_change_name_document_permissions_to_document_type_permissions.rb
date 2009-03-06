class ChangeNameDocumentPermissionsToDocumentTypePermissions < ActiveRecord::Migration
  def self.up
    rename_table :document_permissions, :document_type_permissions
  end

  def self.down
    rename_table :document_type_permissions, :document_permissions
  end
end

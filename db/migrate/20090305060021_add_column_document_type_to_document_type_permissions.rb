class AddColumnDocumentTypeToDocumentTypePermissions < ActiveRecord::Migration
  def self.up
    add_column :document_type_permissions, :document_type_id, :integer
    remove_column :document_type_permissions, :document_owner
  end

  def self.down
    remove_column :document_type_permissions, :document_type_id
    add_column :document_type_permissions, :document_owner, :string
  end
end

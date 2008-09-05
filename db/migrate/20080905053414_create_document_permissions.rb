class CreateDocumentPermissions < ActiveRecord::Migration
  def self.up
    create_table :document_permissions do |t|
      t.boolean :list, :view, :add, :edit, :delete
      t.references :file_type
      t.references :role
      
      t.timestamps
    end
  end

  def self.down
    drop_table :document_permissions
  end
end

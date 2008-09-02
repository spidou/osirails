class CreateDocumentVersions < ActiveRecord::Migration
  def self.up
    create_table :document_versions do |t|
      t.string :description
      t.references :document
      
      t.datetime :versioned_at
    end
  end

  def self.down
    drop_table :document_versions
  end
end

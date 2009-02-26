class DropTableDocumentVersions < ActiveRecord::Migration
  def self.up
    drop_table :document_versions
  end

  def self.down
    create_table :document_versions do |t|
      t.string :name
      t.string :description
      t.references :document
      
      t.datetime :versioned_at
    end
  end
end

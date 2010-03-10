class CreateDocumentTypesMimeTypes < ActiveRecord::Migration
  def self.up
    create_table :document_types_mime_types, :id => false do |t|
      t.references :document_type, :mime_type
    end
  end

  def self.down
    drop_table :document_types_mime_types
  end
end

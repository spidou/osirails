class CreateDocumentSendingMethods < ActiveRecord::Migration
  def self.up
    create_table :document_sending_methods do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :document_sending_methods
  end
end

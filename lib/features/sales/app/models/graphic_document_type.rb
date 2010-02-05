class GraphicDocumentType < ActiveRecord::Base
  # Relationships
  has_many :graphic_documents

  # Validations
  validates_uniqueness_of :name
  validates_presence_of :name
end

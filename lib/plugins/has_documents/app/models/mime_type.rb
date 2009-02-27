class MimeType < ActiveRecord::Base
  has_many :mime_type_extensions
  has_and_belongs_to_many :document_types
end
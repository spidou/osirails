class DocumentTypePermission < ActiveRecord::Base
  belongs_to :document_type
  belongs_to :role
end

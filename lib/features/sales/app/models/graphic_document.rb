class GraphicDocument < GraphicItem
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :cancel]
  has_reference :symbols => [:order], :prefix => :sales
  
  # Relationships
  belongs_to :graphic_document_type

  # Validations
  validates_presence_of :graphic_document_type_id
  validates_presence_of :graphic_document_type, :if => :graphic_document_type_id
  validates_persistence_of :graphic_document_type_id
end

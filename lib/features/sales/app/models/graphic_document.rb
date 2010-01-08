class GraphicDocument < GraphicItem
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :cancel]
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:description] = "Description :"
  @@form_labels[:graphic_document_type] = "Type de document graphique :"
  @@form_labels[:graphic_unit_measure] = "Unité de mesure :"
  @@form_labels[:image] = "Fichier image :"
  @@form_labels[:source] = "Fichier source :"
  @@form_labels[:version] = "Version actuelle :"
  @@form_labels[:created_at] = "Créé le :"
  @@form_labels[:creator] = "Par :"
  @@form_labels[:should_add_version] = "Ajouter une nouvelle version :"
  @@form_labels[:should_change_version] = "Sélectionner une autre version :"
  @@form_labels[:change_version] = "Version :"
  
  # Relationships
  belongs_to :graphic_document_type

  # Validations
  validates_presence_of :graphic_document_type_id
  validates_presence_of :graphic_document_type, :if => :graphic_document_type_id
  validates_persistence_of :graphic_document_type_id
end

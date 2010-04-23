class Mockup < GraphicItem
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :cancel]
  has_reference :symbols => [:order], :prefix => :sales
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:product]               = "Produit :"
  @@form_labels[:name]                  = "Nom :"
  @@form_labels[:description]           = "Description :"
  @@form_labels[:mockup_type]           = "Type de maquette :"
  @@form_labels[:graphic_unit_measure]  = "Unité de mesure :"
  @@form_labels[:image]                 = "Fichier image :"
  @@form_labels[:source]                = "Fichier source :"
  @@form_labels[:version]               = "Version actuelle :"
  @@form_labels[:created_at]            = "Créée le :"
  @@form_labels[:creator]               = "Par :"
  @@form_labels[:should_add_version]    = "Ajouter une nouvelle version :"
  @@form_labels[:should_change_version] = "Sélectionner une autre version :"
  @@form_labels[:change_version]        = "Version :"
  
  # Relationships
  belongs_to :mockup_type
  belongs_to :product

  # Validations
  validates_presence_of :mockup_type_id, :product_id
  validates_presence_of :mockup_type, :if => :mockup_type_id
  validates_presence_of :product,     :if => :product_id
  
  validates_persistence_of :mockup_type_id, :product_id
  
  validate :validates_inclusion_of_product
  
  def validates_inclusion_of_product
    unless (order.nil? or product.nil?)
      errors.add(:product, I18n.t('activerecord.errors.messages.inclusion')) unless order.products.include?(product)
    end
  end
end

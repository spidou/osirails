class SupplySubCategory < SupplyCategory
  belongs_to :unit_measure
  
  has_many :supply_categories_supply_sizes, :include => [ :supply_size ], :order => "supply_sizes.position"
  has_many :supply_sizes, :through => :supply_categories_supply_sizes
  
  validates_presence_of :supply_category_id
  validates_presence_of :supply_category, :if => :supply_category_id
  
  validates_persistence_of :name, :unit_measure_id, :if => :has_children?
  
  validates_associated :supply_categories_supply_sizes
  
  validate :validates_uniqueness_of_supply_sizes
  
  after_save :save_supply_categories_supply_sizes
  
  @@form_labels[:supply_category] = "Famille :"
  @@form_labels[:unit_measure]    = "Grandeur/U :"
  
  def validates_uniqueness_of_supply_sizes
    my_supply_sizes = supply_categories_supply_sizes.collect(&:supply_size)
    errors.add(:supply_categories_supply_sizes, "La même spécificité a été sélectionnée deux fois") if my_supply_sizes.size != my_supply_sizes.uniq.size
  end
  
  def can_be_enabled?
    !enabled? and supply_category.enabled?
  end
  
  # this is an override of the method defined on supply_category.rb
  def children
    supplies
  end
  
  def ancestors
    [ supply_category ] + supply_category.ancestors
  end
  
  def supply_categories_supply_size_attributes=(supply_categories_supply_size_attributes)
    supply_categories_supply_size_attributes.each do |attributes|
      if attributes[:id].blank?
        supply_categories_supply_sizes.build(attributes) unless attributes[:unit_measure_id].blank?
      else
        supply_categories_supply_size = supply_categories_supply_sizes.detect { |t| t.id == attributes[:id].to_i }
        supply_categories_supply_size.attributes = attributes
      end
    end
  end
  
  def save_supply_categories_supply_sizes
    supply_categories_supply_sizes.each do |s|
      if s.should_destroy?
        s.destroy
      else
        s.save(false) if s.changed?
      end
    end
  end
  
end

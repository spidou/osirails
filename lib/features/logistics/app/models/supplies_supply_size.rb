class SuppliesSupplySize < ActiveRecord::Base
  belongs_to :supply
  belongs_to :supply_size
  belongs_to :unit_measure
  
  validates_presence_of :supply_size_id, :unit_measure_id
  validates_presence_of :supply_size,   :if => :supply_size_id
  validates_presence_of :unit_measure,  :if => :unit_measure_id
  
  validates_numericality_of :value, :unless => Proc.new{ |s| s.should_destroy? or s.accept_string? }
  
  before_validation_on_create :set_default_unit_measure
  
  attr_accessor :supply_sub_category_id # store the supply_sub_category_id of the supply, used by Supply#supplies_supply_size_attributes=
  
  def should_destroy?
    value.blank?
  end
  
  def accept_string?
    supply_size ? supply_size.accept_string? : false
  end
  
  # remove useless floating point when possible
  def value
    super.to_i == super ? super.to_i : super
  end
  
  def set_default_unit_measure
    return if unit_measure or should_destroy?
    
    parent_id = supply ? supply.supply_sub_category_id : supply_sub_category_id
    item = SupplyCategoriesSupplySize.find_by_supply_sub_category_id_and_supply_size_id( parent_id, self.supply_size_id )
    self.unit_measure = item.unit_measure if item
  end
end

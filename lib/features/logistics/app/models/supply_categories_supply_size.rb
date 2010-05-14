class SupplyCategoriesSupplySize < ActiveRecord::Base
  belongs_to :supply_sub_category
  belongs_to :supply_size
  belongs_to :unit_measure
  
  validates_presence_of :supply_size_id
  validates_presence_of :supply_size,   :if => :supply_size_id
  
  def should_destroy?
    unit_measure.blank?
  end
end

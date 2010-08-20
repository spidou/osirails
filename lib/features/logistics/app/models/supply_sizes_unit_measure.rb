class SupplySizesUnitMeasure < ActiveRecord::Base
  belongs_to :supply_size
  belongs_to :unit_measure
  
  acts_as_list :scope => :supply_size
  
  validates_presence_of :supply_size_id, :unit_measure_id
  validates_presence_of :supply_size,  :if => :supply_size_id
  validates_presence_of :unit_measure, :if => :unit_measure_id
end

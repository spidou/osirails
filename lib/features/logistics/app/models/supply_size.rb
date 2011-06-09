class SupplySize < ActiveRecord::Base
  has_permissions :as_business_object
  
  acts_as_list
  
  has_many :supply_sizes_unit_measures, :order => 'supply_sizes_unit_measures.position'
  has_many :unit_measures, :through => :supply_sizes_unit_measures, :order => 'supply_sizes_unit_measures.position'
  
  validates_presence_of :name
  
  validates_uniqueness_of :name
  
  def display_short_name?
    display_short_name
  end
  
  def accept_string?
    accept_string
  end
  
  def name_and_short_name
    name + ( short_name.blank? ? "" : " (#{short_name})" )
  end
end

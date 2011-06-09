class SupplyType < SupplyCategory
  validates_presence_of :supply_category_id
  validates_presence_of :supply_sub_category, :if => :supply_category_id
  
  has_search_index :only_attributes => [ :id, :reference, :name ]
  
  def can_be_enabled?
    !enabled? and supply_sub_category.enabled?
  end
  
  # this is an override of the method defined on supply_category.rb
  def children
    supplies
  end
  
  def ancestors
    [ supply_sub_category ] + supply_sub_category.ancestors
  end
end

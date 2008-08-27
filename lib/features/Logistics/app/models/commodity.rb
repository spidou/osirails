class Commodity < ActiveRecord::Base

  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  belongs_to :commodity_category, :counter_cache => true
  
  # Name Scope
  named_scope :activates, :conditions => {:enable => true}

  def counter_update
    parent = CommodityCategory.find(self.commodity_category_id)
    CommodityCategory.update_counters(parent.id, :commodities_count => -1)
    grand_parent = CommodityCategory.find(parent.commodity_category_id)
    CommodityCategory.update_counters(grand_parent.id, :commodities_count => -1)
  end
  
  def can_destroy?
    false
  end

end

class Commodity < ActiveRecord::Base

  # Plugin
  # acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  belongs_to :commodity_category, :counter_cache => true
  
  # Name Scope
  named_scope :activates, :conditions => {:enable => true}
  
  # Validates
  validates_presence_of :name, :fob_unit_price, :unit_mass, :measure, :taxe_coefficient, :message => "ne peut être vide."
  validates_numericality_of :fob_unit_price, :unit_mass, :measure, :taxe_coefficient, :message => "ne peut être des lettres."

  # This method permit to actualize counter_cache if a commodity is disable
  def counter_update
    parent = CommodityCategory.find(self.commodity_category_id)
    CommodityCategory.update_counters(parent.id, :commodities_count => -1)
    grand_parent = CommodityCategory.find(parent.commodity_category_id)
    CommodityCategory.update_counters(grand_parent.id, :commodities_count => -1)
  end
  
  # Check if a resource can be destroy or disable
  def can_destroy?
    false
  end

end
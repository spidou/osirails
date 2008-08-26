class CommodityCategory < ActiveRecord::Base
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  has_many :commodities
  has_many :commodity_categories
  
  # Name Scope
  named_scope :activates, :conditions => {:enable => true}
  named_scope :root,  :order => 'name', :conditions => {:enable => true, :commodity_category_id => nil}
  named_scope :root_child, :conditions => 'commodity_category_id is not null and enable is true'

  def can_destroy?
    self.commodity_categories.empty? and self.commodities.empty?
  end
end
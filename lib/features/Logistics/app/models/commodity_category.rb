class CommodityCategory < ActiveRecord::Base
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  has_many :commodities
  has_many :commodity_categories
  
  # Name Scope
  named_scope :activates, :conditions => {:enable => true}
  named_scope :root, :conditions => {:enable => true, :commodity_category_id => nil}
  named_scope :root_child, :conditions => 'commodity_category_id is not null and enable is true'
  
  # Validates
  validates_presence_of :name, :message => "ne peut être vide."

  # Check if a resource can be destroy or disable
  def can_destroy?
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => self.id, :enable => true})
    categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => self.id, :enable => true})
    commodities.empty? and categories.empty?
  end
  
  # Check if a category have got children disable
  def has_children_disable?
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => self.id, :enable => false})
    categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => self.id, :enable => false})
    commodities.size > 0 or categories.size > 0
  end
  
end
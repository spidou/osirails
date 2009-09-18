class CommodityCategory < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  has_many :commodities
  has_many :commodity_categories
  belongs_to :commodity_category
  
  # Named Scope
  named_scope :activates, :conditions => {:enable => true}
  named_scope :root, :conditions => {:enable => true, :commodity_category_id => nil}
  named_scope :root_child, :conditions => 'commodity_category_id is not null and enable is true'
  
  # Validates
  validates_presence_of :unit_measure_id, :if => :commodity_category_id, :message => "à renseigner"
  validates_presence_of :name, :message => "ne peut être vide"
  validates_uniqueness_of :name, :message => "doit être unique"

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:commodity_category] = "Appartient &agrave; :"
  @@form_labels[:unit_measure] = "Unit&eacute;e de mesure :"

  # Check if a resource should be destroyed or disabled
  def can_be_destroyed?
    self.commodity_categories.empty? and self.commodities.empty?
  end
  
  # Check if a category have got children disable
  def has_children_disable?
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => self.id, :enable => false})
    categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => self.id, :enable => false})
    commodities.size > 0 or categories.size > 0
  end
  
  # Returns the stock value according to its children category or 
  # directly to its commodities stock value
  def stock_value(date=Date.today)
    subordinates = CommodityCategory.root.include?(self) ? self.children : self.commodities
    total = 0.0
    for subordinate in subordinates
      total += subordinate.stock_value(date)
    end
    total
  end
end

class CommodityCategory < ActiveRecord::Base
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :reactivate]
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  has_many :commodities
  has_many :commodity_categories
  belongs_to :commodity_category
  
  # Named Scope
  named_scope :root, :conditions => {:enable => true, :commodity_category_id => nil}
  named_scope :root_including_inactives, :conditions => {:commodity_category_id => nil}
  named_scope :root_child, :conditions => 'commodity_category_id is not null and enable is true'
    
  # This method returns all categories at a given date
  # TODO with a named_scope (with argument) or not ?
  def self.was_enabled_at(date=Date.today)
    self.find(:all, :conditions => ["(enable = 1) OR (enable = 0 AND disabled_at > ?)", date])
  end
  
  # Validates
  validates_presence_of :unit_measure_id, :if => :commodity_category_id
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_persistence_of :name, :commodity_category_id, :unit_measure_id, :unless => :enable
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:commodity_category] = "Appartient à :"
  @@form_labels[:unit_measure] = "Unité de mesure :"  
  
  # This method prevent from remove if it is not authorized
  # Override is necessary because before_destroy callback 
  # used by the act_as_tree plugin empty all children before
  def destroy
    return false unless self.can_be_destroyed?
    super
  end

  # This method defines when it can be destroyed
  def can_be_destroyed?
    self.commodity_categories.empty? and self.commodities.empty? and !self.has_children_disabled?
  end
  
  # This method defines when it can be disabled
  def can_be_disabled?
    self.enable and !self.has_children_enabled?
  end  
  
  # This method defines when it can be reactivated
  def can_be_reactivated?
    unless commodity_category.nil?
      !self.enable and self.commodity_category.enable
    else
      !self.enable
    end
  end 
  
  # This method permit to disable a category
  def disable
    if self.can_be_disabled?
      self.enable = false
      self.disabled_at = Time.now
      self.save
    end
  end
  
  # This method permit to reactivate a category
  def reactivate
    if can_be_reactivated?
      self.enable = true
      self.disabled_at = nil
      self.save
    end
  end
  
  # Check if a category have got children disabled
  def has_children_disabled?
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => self.id, :enable => false})
    categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => self.id, :enable => false})
    commodities.size > 0 or categories.size > 0
  end
  
  # Check if a category have got children enabled
  def has_children_enabled?
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => self.id, :enable => true})
    categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => self.id, :enable => true})
    commodities.size > 0 or categories.size > 0
  end
  
  # Returns the stock value according to its children category or 
  # directly to its commodities stock value
  def stock_value(date=Date.today)
    subordinates_type = (CommodityCategory.root_including_inactives.include?(self) ? 'category' : 'commodity')
    subordinates = (subordinates_type=='category' ? self.children : self.commodities)
    total = 0.0
    for subordinate in subordinates
      total += subordinate.stock_value(date) unless (subordinates_type == 'commodity' and !Commodity.was_enabled_at(date).include?(subordinate)) 
    end
    total
  end
end

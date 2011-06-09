class SupplyCategory < ActiveRecord::Base
  validates_presence_of :name, :reference
  
  validates_uniqueness_of :name,      :scope => [ :type, :supply_category_id ]
  validates_uniqueness_of :reference, :scope => :type #TODO test if it's not conflicting with validates_uniqueness_of in has_reference.rb
  
  validates_presence_of :disabled_at, :unless => :enabled?
  
  validates_persistence_of :reference
  
  named_scope :enabled, :conditions => { :enabled => true }
  named_scope :enabled_at, lambda{ |date| { :conditions => [ 'enabled = ? OR disabled_at > ?', true, date ] } }
  
  before_validation_on_create :update_reference
  
  before_destroy :can_be_destroyed?
  
  has_search_index :only_attributes => [ :id, :reference, :name ]
   
  def enabled?
    enabled
  end
  
  def can_be_edited?
    enabled?
  end
  
  def can_have_children?
    enabled?
  end
  
  def can_be_destroyed?
    !has_children?
  end
  
  def can_be_disabled?
    enabled? and !has_enabled_children?
  end  
  
  def can_be_enabled?
    !enabled?
  end
  
  def disable
    if self.can_be_disabled?
      self.enabled = false
      self.disabled_at = Time.now
      self.save!
    end
  end
  
  def enable
    if can_be_enabled?
      self.enabled = true
      self.disabled_at = nil
      self.save
    end
  end
  
  def children
    sub_categories
  end
  
  def ancestors; [] end
  
  def self_and_siblings
    @self_and_siblings ||= []
    return @self_and_siblings unless @self_and_siblings.empty?
    
    @self_and_siblings << self if new_record?
    @self_and_siblings += self.class.all
  end
  
  def siblings
    @siblings ||= self_and_siblings - [ self ]
  end
  
  # override the orignal method unless it's the last level of supply_category
  def supplies_count
    if respond_to?(:supply_sub_category)
      super
    else
      children.collect(&:supplies_count).sum
    end
  end
  
  # return if category was enabled at a given date
  def was_enabled_at(date = Time.zone.now)
    enabled? or (!enabled? and disabled_at > date.to_datetime)
  end
  
  def has_children?
    children.to_a.any?
  end
  
  def has_enabled_children?
    children.enabled.any?
  end
  
  # return the sum of stock_value of all its supplies
  def stock_value(date = Time.zone.now)
    children.select{ |e| e.was_enabled_at(date) }.collect{ |e| e.stock_value(date) }.sum
  end
end

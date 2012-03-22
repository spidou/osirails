## DATABASE STRUCTURE
# A integer  "supply_type_id"
# A string   "type"
# A string   "reference"
# A string   "packaging"
# A decimal  "measure",        :precision => 65, :scale => 18
# A decimal  "unit_mass",      :precision => 65, :scale => 18
# A decimal  "threshold",      :precision => 65, :scale => 18
# A boolean  "enabled",                                        :default => true
# A datetime "disabled_at"
# A datetime "created_at"
# A datetime "updated_at"

class Supply < ActiveRecord::Base # @abstract
  has_many :supplier_supplies
  has_many :suppliers, :through => :supplier_supplies
  
  has_many :stock_flows,   :order => "created_at DESC"
  has_many :stock_inputs,  :order => "created_at DESC"
  has_many :stock_outputs, :order => "created_at DESC"
  
  has_many :supplies_supply_sizes, :include => [ :supply_size ], :order => "supply_sizes.position"
  has_many :supply_sizes, :through => :supplies_supply_sizes
  
  named_scope :enabled, :conditions => { :enabled => true }
  
  validates_presence_of :reference, :supply_type_id
  validates_presence_of :supply_type, :if => :supply_type_id
  
  validates_numericality_of :unit_mass, :greater_than             => 0, :allow_blank => true
  validates_numericality_of :packaging, :greater_than             => 1, :allow_blank => true
  validates_numericality_of :threshold, :greater_than_or_equal_to => 0
  
  validates_numericality_of :measure, :greater_than => 0, :if     => :unit_measure
  validates_inclusion_of    :measure, :in => [nil],       :unless => :unit_measure
  
  validates_persistence_of :supply_type_id, :reference, :measure, :unit_mass, :supplies_supply_sizes, :if => :has_been_used?
  
  validates_associated :supplier_supplies, :supplies_supply_sizes
  
  validate :validates_uniqueness_of_supplies_supply_sizes_scoped_by_supply_type
  validate :validates_supplies_supply_sizes_according_to_sub_category
  
  before_validation_on_create :update_reference
  before_validation :find_or_build_supply_type
  
  after_save :save_supplier_supplies, :save_supplies_supply_sizes
  
  SUPPLIES_PER_PAGE = 15
  
  attr_accessor  :supply_type_name
  attr_accessor  :supply_category_id, :supply_sub_category_id # correspond to the parents of the supply_type associated to the supply
  
  def validates_uniqueness_of_supplies_supply_sizes_scoped_by_supply_type
    return unless supply_type and siblings.any?
    
    similar_supply = nil
    current_values = supplies_supply_sizes.reject(&:should_destroy?).collect{ |sss| [sss.supply_size_id, sss.unit_measure_id, sss.value] }
    
    siblings.each do |sibling|
      sibling_values = sibling.supplies_supply_sizes.collect{ |sss| [sss.supply_size_id, sss.unit_measure_id, sss.value] }
      
      next if current_values.size != sibling_values.size
      
      matching_sizes = current_values.collect do |current_sss|
        current_sss if sibling_values.include?(current_sss)
      end.compact
      
      if matching_sizes.size == sibling_values.size
        similar_supply = sibling
        break
      end
    end
    
    if similar_supply
      errors.add(:supplies_supply_sizes, "La famille choisie contient déjà un article avec le même type et les mêmes spécificités (#{similar_supply.reference} - #{similar_supply.designation})")
      errors.add(:supply_type, I18n.t('activerecord.errors.messages.taken'))
      supplies_supply_sizes.reject(&:should_destroy?).each do |size|
        size.errors.add(:value, I18n.t('activerecord.errors.messages.taken'))
      end
    end
  end
  
  def validates_supplies_supply_sizes_according_to_sub_category
    return unless supply_sub_category
    
    sub_category_sizes_and_unit_measures = supply_sub_category.supply_categories_supply_sizes.map{ |s| [ s.supply_size_id, s.unit_measure_id ] }
    
    error_counter = 0
    supplies_supply_sizes.each do |supplies_supply_size|
      item = [ supplies_supply_size.supply_size_id, supplies_supply_size.unit_measure_id ]
      error_counter += 1 unless sub_category_sizes_and_unit_measures.include?(item)
    end
    
    errors.add(:supplies_supply_sizes, "Les spécificités de l'article ne correspondent pas à celles de la sous-famille choisie") unless error_counter.zero?
  end
  
  # This callback prevent from destroy if it is not authorized
  def before_destroy #TODO test this method
    unless can_be_destroyed?
      update_supply_type_counter # IMPORTANT because the decrement counter is called before this callback
      return false 
    end
  end
  
  # This method returns all enabled supplies at a given date
  def self.was_enabled_at(date = Time.zone.now)
    #OPTIMIZE use a sql statement
    self.all.select{ |s| s.was_enabled_at(date) }
  end
  
  # This method returns all the restockables supplies (defined by a stock less than 10% above the given threshold)
  def self.restockables
    #OPTIMIZE use a sql statement
    self.was_enabled_at.select{ |s| s.stock_quantity < ( s.threshold * 1.1 ) }
  end
  
  # This method returns the entire stock values
  def self.stock_value(date = Time.zone.now)
    #OPTIMIZE use a sql statement
    self.was_enabled_at(date).collect{ |s| s.stock_value(date) }.sum
  end
  
  def enabled?
    enabled
  end
  
  #TODO test this method
  def sorted_supplies_supply_sizes(force_reload = false)
    supplies_supply_sizes(force_reload).sort_by{ |sss| sss.supply_size && sss.supply_size.position || 0 }
  end
  
  def humanized_supply_sizes(force_reload = false)
    @humanized_supply_sizes = ""
    
    sorted_supplies_supply_sizes(force_reload).each_with_index do |item, index|
      next_item = supplies_supply_sizes[index.next]
      unit_measure = ( next_item && next_item.unit_measure_id == item.unit_measure_id ) ? "" : item.unit_measure && item.unit_measure.symbol
      
      @humanized_supply_sizes << item.supply_size.short_name if item.supply_size.display_short_name?
      @humanized_supply_sizes << item.value.to_s
      if next_item
        if next_item.unit_measure_id == item.unit_measure_id
          @humanized_supply_sizes << " x "
        else
          @humanized_supply_sizes << " #{unit_measure}, "
        end
      else
        @humanized_supply_sizes << " #{unit_measure}"
      end
    end
    
    return @humanized_supply_sizes
  end
  
  def designation(force_reload = false)
    return unless supply_category and supply_sub_category and supply_type
    "#{supply_category.name} #{supply_sub_category.name} #{supply_type.name} #{humanized_supply_sizes(force_reload)}".strip
  end
  
  def threshold
    self[:threshold] || 0
  end
  
  def supply_sub_category
    if supply_type
      supply_type.supply_sub_category
    elsif @supply_sub_category_id
      SupplySubCategory.find_by_id(@supply_sub_category_id)
    end
  end
  
  def supply_sub_category_id=(id)
    @supply_sub_category_id = id.to_i
  end
  
  def supply_sub_category_id
    @supply_sub_category_id ||= supply_sub_category && supply_sub_category.id
  end
  
  def supply_category
    if supply_sub_category
      supply_sub_category.supply_category
    elsif @supply_category_id
      SupplyCategory.find_by_id(@supply_category_id)
    end
  end
  
  def supply_category_id=(id)
    @supply_category_id = id.to_i
  end
  
  def supply_category_id
    @supply_category_id ||= supply_category && supply_category.id
  end
  
  #delegate :unit_measure, :to => :supply_sub_category, :allow_nil => true #TODO uncomment this part of code and remove the following method once we have migrated to rails 2.3.2
  def unit_measure
    supply_sub_category && supply_sub_category.unit_measure
  end
  
  # return the class of the parent
  def supply_type_class
    self.class.reflect_on_association(:supply_type).klass
  end
  
  def can_be_edited?
    enabled? and !new_record?
  end
  
  def can_be_destroyed?
    enabled? and !has_been_used?
  end
  
  def can_be_disabled?
    enabled? and stock_quantity.zero?
  end  
  
  def can_be_enabled?
    !enabled? and supply_sub_category.enabled?
  end
  
  def ancestors
    supply_type ? [supply_type] + supply_type.ancestors : []
  end
  
  def self_and_siblings
    @self_and_siblings = []
    @self_and_siblings << self if new_record?
    @self_and_siblings += supply_type_class.find(supply_type_id).supplies
  rescue ActiveRecord::RecordNotFound
    @self_and_siblings = []
  end
  
  def siblings
    self_and_siblings - [ self ]
  end
  
  # return if the supply has already been used by a stock flow
  def has_been_used?
    StockFlow.find_by_supply_id(self.id) ? true : false
  end
  
  def disable
    if can_be_disabled?
      self.enabled = false
      self.disabled_at = Time.zone.now
      if self.save
        update_supply_type_counter(false)
      end
    end
  end
  
  def enable
    if can_be_enabled?
      self.enabled = true
      self.disabled_at = nil
      if self.save
        update_supply_type_counter
      end
    end
  end  
    
  # This method determines if a supply was enabled_at a given date
  def was_enabled_at(date = Time.zone.now)
    enabled? or (!enabled? and disabled_at > date)
  end
  
  # return the last stock_flow at the given date
  def last_stock_flow(date = Time.zone.now)
    StockFlow.last(:conditions => [ "supply_id = ? AND created_at < ?", self.id, date.to_s(:db) ]) # don't use the relationship method 'stock_flows' to avoid getting new records
  end
  
  # return the last inventory at the given date
  def last_inventory(date = Time.zone.now)
    Inventory.last(:conditions => [ "supply_class = ? AND created_at < ?", self.class.name, date.to_s(:db) ])
  end
  
  # return the last stock_flow providing by an inventory, at the given date
  def last_inventory_stock_flow(date = Time.zone.now)
    if inventory = last_inventory(date)
      if stock_flow = inventory.stock_flows.find_by_supply_id(self.id)
        return stock_flow
      else
        return last_stock_flow( inventory.date )
      end
    end
  end

  # return the stock quantity at the given date
  def stock_quantity(date = Time.zone.now)
    last_stock_flow(date) ? last_stock_flow(date).current_stock_quantity : 0
  end
  
  # return the stock quantity stored at the last inventory from the given date
  def stock_quantity_at_last_inventory(date = Time.zone.now)
    last_inventory_stock_flow(date) ? last_inventory_stock_flow(date).current_stock_quantity : 0
  end

  def stock_value(date = Time.zone.now)
    last_stock_flow(date) ? last_stock_flow(date).current_stock_value : 0.0
  end
  
  def stock_measure(date = Time.zone.now)
    measure ? stock_quantity(date) * measure : 0.0
  end
  
  def stock_mass(date = Time.zone.now)
    unit_mass ? stock_quantity(date) * unit_mass : 0.0
  end

  # returns the average unit value of the stock
  def average_unit_stock_value(date = Time.zone.now)
    stock_quantity(date).zero? ? 0.0 : stock_value(date) / stock_quantity(date)
  end
  
  def average_measure_stock_value(date = Time.zone.now)
    return 0.0 unless measure
    stock_quantity(date).zero? ? 0.0 : average_unit_stock_value(date) / measure
  end
  
  def supplier_supplies_unit_prices
    supplier_supplies.reject(&:new_record?).collect(&:unit_price)
  end
  
  def average_unit_price
    (supplier_supplies_unit_prices.sum / supplier_supplies_unit_prices.size) if supplier_supplies_unit_prices.any?
  end
  
  def average_measure_price
    average_unit_price && measure && measure > 0 && average_unit_price / measure
  end
  
  def higher_unit_price
    supplier_supplies_unit_prices.max
  end
  
  def higher_measure_price
    higher_unit_price && measure && measure > 0 && higher_unit_price / measure
  end
  
  def unit_price
    average_unit_price
  end
  
  def measure_price
    average_measure_price
  end
  
  def supplier_supply_attributes=(supplier_supply_attributes)
    supplier_supply_attributes.each do |attributes|
      attributes = attributes.to_hash if attributes.is_a?(ActiveSupport::OrderedHash) # it can be deleted once we use ruby1.9
      
      if attributes[:id].blank?
        supplier_supplies.build(attributes) unless attributes[:supplier_id].blank?
      else
        supplier_supply = supplier_supplies.detect { |t| t.id == attributes[:id].to_i }
        supplier_supply.attributes = attributes
      end
    end
  end

  def save_supplier_supplies
    supplier_supplies.each do |s|
      if s.should_destroy?
        s.destroy
      elsif s.changed?
        s.save(false)
      end
    end
  end
  
  def supplies_supply_size_attributes=(supplies_supply_size_attributes)
    supplies_supply_size_attributes.each do |attributes|
      attributes = attributes.to_hash if attributes.is_a?(ActiveSupport::OrderedHash) # it can be deleted once we use ruby1.9
      attributes.merge!({ :supply_sub_category_id => supply_sub_category_id })
      
      if attributes[:id].blank?
        supplies_supply_sizes.build(attributes) unless attributes[:value].blank?
      else
        supplies_supply_size = supplies_supply_sizes.detect { |t| t.id == attributes[:id].to_i }
        supplies_supply_size.attributes = attributes
      end
    end
  end
  
  def save_supplies_supply_sizes
    supplies_supply_sizes.each do |s|
      if s.should_destroy?
        s.destroy
      else
        s.save(false) if s.changed?
      end
    end
  end
  
  def stock_quantity_smaller_than_threshold?
    stock_quantity < threshold
  end
  
  def stock_quantity_at_last_inventory_smaller_than_threshold?
    stock_quantity_at_last_inventory < threshold
  end
  
  private
    #TODO test this method
    def update_supply_type_counter(increment = true)
      method = ( increment ? "increment" : "decrement" ) + "_counter"
      self.supply_type.class.send(method, :supplies_count, supply_type.id)
    end
    
    #TODO test this method
    def find_or_build_supply_type
      return if supply_type_name.blank? or supply_sub_category_id.blank?
      supply_type = supply_type_class.find_by_name_and_supply_category_id(supply_type_name, supply_sub_category_id) ||
                    supply_type_class.create(:name => supply_type_name, :supply_category_id => supply_sub_category_id)
      self.supply_type_id = supply_type.id
    end
end

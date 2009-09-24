class Supply < ActiveRecord::Base
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :reactivate]
  
  # Relationships
  has_many :supplier_supplies
  has_many :suppliers, :through => :supplier_supplies
  has_many :stock_flows

  # Validates
  validates_presence_of :name, :reference
  validates_numericality_of :unit_mass, :measure, :threshold
  validates_persistence_of :name, :reference, :measure, :unit_mass, :commodity_category_id, :consumable_category_id, :if => :persistence_case?
  
  # This method defines when persistence has to be
  def persistence_case?
    self.has_been_used? or !self.enable
  end
  
  after_update :save_supplier_supplies
  
  SUPPLIES_PER_PAGE = 15

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]                = "Désignation :"
  @@form_labels[:reference]           = "Référence :"
  @@form_labels[:commodity_category]  = "Catégorie :"
  @@form_labels[:consumable_category] = "Catégorie :"
  @@form_labels[:supplier]            = "Fournisseur principal :"
  @@form_labels[:unit_mass]           = "Masse/U (kg) :"
  @@form_labels[:average_unit_price]  = "Prix/U moyen :"
  @@form_labels[:threshold]           = "Quantité de stock minimum :"
  @@form_labels[:stock_quantity]      = "Quantité de stock totale :"
  @@form_labels[:stock_measure]       = "Grandeur totale :"
  @@form_labels[:stock_value]         = "Valeur totale :"
  @@form_labels[:stock_mass]          = "Poids total :"
  
  # This callback prevent from destroy if it is not authorized
  def before_destroy
    unless self.can_be_destroyed?
      update_category_counter # IMPORTANT because the decrement counter is called before this callback
      return false 
    end
  end
  
  # This method defines when it can be destroyed
  def can_be_destroyed?
    !self.has_been_used?
  end
  
  # This method defines when it can be disabled
  def can_be_disabled?
    self.enable and self.stock_quantity == 0
  end  
  
  # This method defines when it can be reactivated
  def can_be_reactivated?
    !self.enable and self.send(self.class.name.underscore+"_category").enable
  end  
  
  # This method permit to determine if the supply has already been
  # treated by a stock flow
  def has_been_used?
    true if StockFlow.find_by_supply_id(self.id)
  end
  
  # This method update the category counter
  def update_category_counter(increment=true)
    (self.class.name + "Category").constantize.send("#{increment ? "increment":"decrement"}_counter",(self.class.name.tableize+"_count").to_sym,self.send(self.class.name.underscore+"_category").id)
  end
  
  # This method permit to disable a supply
  def disable
    if self.can_be_disabled?
      self.enable = false
      self.disabled_at = Time.now
      update_category_counter(false)
      self.save
    end
  end  
  
  # This method permit to reactive a supply
  def reactivate
    if self.can_be_reactivated?
      self.enable = true
      self.disabled_at = nil
      update_category_counter
      self.save
    end
  end

  # This method returns the total stock according to
  # all supplier_supplies' stocks
  def stock_quantity(date=Date.today)
    total = 0.0
    for supplier_supply in self.supplier_supplies
      total += supplier_supply.stock_quantity(date)
    end
    total
  end

  # This method returns the average unit price
  # according to all supplier_supplies' unit prices
  def stock_value(date=Date.today)
    total = 0.0
    for supplier_supply in self.supplier_supplies
      total += supplier_supply.stock_value(date)
    end
    total
  end

  # This method returns the average unit price
  # according to all supplier_supplies' unit prices
  def average_unit_price(date=Date.today)
    total = 0.0
    for supplier_supply in self.supplier_supplies
      total += supplier_supply.average_unit_price(date)
    end
    if (self.stock_quantity(date) == 0.0 and self.supplier_supplies.size > 0)
      total/self.supplier_supplies.size
    elsif self.stock_quantity(date) != 0.0
      self.stock_value(date)/(self.stock_quantity(date)*self.measure) 
    end
  end
  
  # This method returns all the restockables
  # supplies. They are defined by a stock less than 10%
  # above the given threshold
  def self.restockables
    @supplies_to_restock = []
    self.find(:all).each {|supply|
      if supply.stock_quantity < (supply.threshold + supply.threshold*0.1)
        @supplies_to_restock << supply
      end
    }
    @supplies_to_restock
  end
  
  # The next methods permit to associate a supplier_supply to a supply
  def supplier_supply_attributes=(supplier_supply_attributes)
    supplier_supply_attributes.each do |attributes|
      if attributes[:id].blank?
        supplier_supplies.build(attributes)
      else
        supplier_supply = supplier_supplies.detect { |t| t.id == attributes[:id].to_i }
        supplier_supply.attributes = attributes
      end
    end
  end

  def save_supplier_supplies
    supplier_supplies.each do |c|
      if c.should_destroy?
        supplier_supplies.delete(c) # delete the supplier supply from the list, but does not delete the supplier_supply itself
      elsif c.should_update?
        c.save(false)
      end
    end
  end
end

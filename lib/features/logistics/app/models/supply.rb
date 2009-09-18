class Supply < ActiveRecord::Base
  has_permissions :as_business_object

  has_many :supplier_supplies
  has_many :suppliers, :through => :supplier_supplies
  has_many :stock_flows

  # Name Scope
  named_scope :activates, :conditions => {:enable => true}

  # Validates
  validates_uniqueness_of :name, :reference
  validates_presence_of :name, :reference
  validates_numericality_of :unit_mass, :measure, :threshold
  #TODO uncomment this after commit and create tests
  #validates_persistence_of :name, :reference, :type, :measure, :unit_mass, :commodity_category_id, :consumable_category_id, :if => :has_been_used?
  
  after_update :save_supplier_supplies

  cattr_reader :form_labels#TODO uncomment this after commit and create tests
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

  def after_destroy
    self.counter_update(1)
  end

  # Check if a resource should be destroy or disable
  def can_be_destroyed?
    #TODO code the method can_be_destroyed? for supply
    false
  end
  
  # This method permit to determine if the supply has already been
  # treated by a stock flow
  #TODO uncomment this after commit and create tests
#  def has_been_used?
#    true if StockFlow.find_by_supply_id(self.id)
#  end

  # This method permit to return the total stock according to
  # all supplier_supplies' stocks
  def stock_quantity(date=Date.today)
    total = 0.0
    for supplier_supply in self.supplier_supplies
      total += supplier_supply.stock_quantity(date)
    end
    total
  end

  # This method permit to return the average unit price
  # according to all supplier_supplies' unit prices
  def stock_value(date=Date.today)
    total = 0.0
    for supplier_supply in self.supplier_supplies
      total += supplier_supply.stock_value(date)
    end
    total
  end

  # This method permit to return the average unit price
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

  # This method permit to return all the restockables
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
        supplier_supplies.delete(c) # delete the supplier_supply from the list, but dont delete the supplier_supply itself
      elsif c.should_update?
        c.save(false)
      end
    end
  end

end


class SupplierSupply < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :supply
  belongs_to :supplier
  
  validates_presence_of :supplier_id, :unless => :should_destroy?
  validates_presence_of :supplier,    :if     => :supplier_id
  
  validates_uniqueness_of :supplier_id, :scope => :supply_id
  
  validates_numericality_of :fob_unit_price, :taxes,  :greater_than_or_equal_to => 0
  validates_numericality_of :lead_time,               :greater_than_or_equal_to => 0, :allow_blank => true
  
  validates_persistence_of :supply_id
  validates_persistence_of :supplier_id, :unless => :should_destroy?
  
  attr_accessor :should_destroy
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supplier]            = "Fournisseur :"
  @@form_labels[:supplier_reference]  = "Référence fournisseur :"
  @@form_labels[:fob_unit_price]      = "Prix HT :"
  @@form_labels[:taxes]               = "Taxes :"
  @@form_labels[:lead_time]           = "Délai d'approvisionnement :"
  
  def should_destroy?
    should_destroy.to_i == 1 or supplier_id.blank?
  end
  
  def unit_price
    return fob_unit_price if taxes.nil? or taxes.zero?
    fob_unit_price * ( 1 + ( taxes / 100.0 ) )
  end
  
  def fob_measure_price
    (fob_unit_price / supply.measure) if supply and supply.measure and supply.measure != 0
  end
  
  def measure_price
    (unit_price / supply.measure) if supply and supply.measure and supply.measure != 0
  end
end

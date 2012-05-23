## DATABASE STRUCTURE
# A integer  "supplier_id"
# A integer  "supply_id"
# A string   "supplier_reference"
# A integer  "lead_time"
# A decimal  "fob_unit_price",     :precision => 65, :scale => 18
# A decimal  "taxes",              :precision => 65, :scale => 18
# A datetime "created_at"
# A datetime "updated_at"

class SupplierSupply < ActiveRecord::Base
  belongs_to :supply
  belongs_to :supplier
  
  validates_presence_of :supplier_id, :unless => :should_destroy?
  validates_presence_of :supplier,    :if     => :supplier_id
  
  validates_numericality_of :fob_unit_price, :taxes,  :greater_than_or_equal_to => 0
  validates_numericality_of :lead_time,               :greater_than_or_equal_to => 0, :allow_blank => true
  
  validates_persistence_of :supply_id
  validates_persistence_of :supplier_id, :unless => :should_destroy?
  
  journalize :attributes        => [:supplier_id, :supplier_reference, :fob_unit_price, :taxes, :lead_time],
             :identifier_method => Proc.new{ |s| "#{s.supplier.name}" }
  
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
    return 0.0 if fob_unit_price.nil?
    return fob_unit_price if taxes.nil? or taxes.zero?
    fob_unit_price * ( 1 + ( taxes / 100 ) )
  end
end

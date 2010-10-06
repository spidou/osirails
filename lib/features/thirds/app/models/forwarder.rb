class Forwarder < Third
  include SiretNumber
  include SupplierBase
  include CustomerBase
  
  has_permissions :as_business_object
  
  has_many :departures
  has_many :forwarder_conveyances
  has_many :conveyances, :through => :forwarder_conveyances
  has_many :quotation_forwarders
#  has_many :quotations, :through => :quotation_forwarders, :class_name => "Forwarder", :foreign_key => "forwarder_id"
  
  validates_uniqueness_of :name, :scope => :type, :message => "Ce nom existe déjà."
  
  FORWARDER_PER_PAGE = 15
  
#  validates_length_of :conveyances, :minimum => 1, :message => "Vous devez entrer au moins un moyen de transport" # nécessaire?
  
  validates_associated :conveyances, :forwarder_conveyances
  
  after_save :save_forwarder_conveyances, :destroy_unselected_forwarder_conveyances
  
  has_search_index :only_attributes    => [:name, :siret_number],
                   :only_relationships => [:legal_form, :iban],
                   :main_model         => true
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]        = "Raison sociale :"
  @@form_labels[:departure]   = "Point de départ :"
  @@form_labels[:conveyance]  = "Moyen de transport :"
  
  attr_accessor :conveyances_ids
  attr_accessor :departures_ids
  
  def activated_conveyances
    conveyances.select(&:activated)
  end
  
  def activated_departures
    departures.select(&:activated)
  end
  
  def forwarder_conveyances_attributes=(conveyances_attributes)
    @conveyances_ids = conveyances_ids = conveyances_attributes.collect{ |conveyance_attributes| conveyance_attributes[:forwarder_conveyance_ids].to_i }
    conveyances_ids.each do |conveyance_id|
      unless forwarder_conveyances.detect{ |forwarder_conveyance| conveyance_id == forwarder_conveyance.conveyance_id }
        self.forwarder_conveyances.build(:conveyance_id => conveyance_id, :forwarder_id => self.id)
      end
    end
  end
  
  def destroy_unselected_forwarder_conveyances
    @conveyances_ids ||= []
    self.forwarder_conveyances.each{|forwarder_conveyance| forwarder_conveyance.destroy() unless @conveyances_ids.detect{|conveyance_id| conveyance_id == forwarder_conveyance.conveyance_id} }
  end
  
#  def forwarder_departures_attributes=(departures_attributes)
#    @departures_ids = departures_ids = departures_attributes.collect{ |departure_attributes| departure_attributes[:forwarder_departure_ids].to_i }
#    departures_ids.each do |departure_id|
#      unless forwarder_departures.detect{ |forwarder_departure| departure_id == forwarder_departure.departure_id }
#        self.forwarder_departures.build(:departure_id => departure_id, :forwarder_id => self.id)
#      end
#    end
#  end
#  
#  def destroy_unselected_forwarder_departures
#    @departures_ids ||= []
#    self.forwarder_departures.each{ |forwarder_departure| forwarder_departure.destroy() unless @departures_ids.detect{|departure_id| departure_id == forwarder_departure.departure_id} }
#  end
  
  def save_forwarder_departures
#    self.forwarder_departures.each{ |forwarder_departure| forwarder_departure.save(false)}
  end
  
  def save_forwarder_conveyances
#    self.forwarder_conveyances.each{ |forwarder_conveyance| forwarder_conveyance.save(false)}
  end
  
  def can_be_destroyed?
#    quotations.empty?
    true
  end
  
end

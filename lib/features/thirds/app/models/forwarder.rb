class Forwarder < Third
  include SiretNumber
#  include CustomerBase
  
  has_permissions :as_business_object
  
  has_many :departures, :dependent => :delete_all
  has_many :forwarder_conveyances, :dependent => :delete_all
  has_many :conveyances, :through => :forwarder_conveyances
#  has_many :quotation_forwarders
#  has_many :quotations, :through => :quotation_forwarders

  belongs_to :creator, :class_name => 'User'
  
  validates_uniqueness_of :name, :scope => :type, :message => "Ce nom existe déjà."
  
  named_scope :activates, :conditions => { :activated => true }
  
  FORWARDER_PER_PAGE = 15
  
  validates_associated :forwarder_conveyances
  
  after_save :save_departures, :destroy_unselected_forwarder_conveyances
  
  has_search_index :only_attributes    => [:name, :siret_number],
                   :only_relationships => [:legal_form],
                   :main_model         => true
  
  @@form_labels[:name]        = "Raison sociale :"
  @@form_labels[:departure]   = "Point de départ :"
  @@form_labels[:conveyance]  = "Moyen de transport :"
  
  attr_accessor :conveyances_ids
  
  def forwarder_conveyances_attributes=(conveyances_attributes)
    @conveyances_ids = conveyances_ids = conveyances_attributes.collect{ |conveyance_attributes| conveyance_attributes[:forwarder_conveyance_ids].to_i }
    conveyances_ids.each do |conveyance_id|
      unless forwarder_conveyances.detect{ |forwarder_conveyance| conveyance_id == forwarder_conveyance.conveyance_id }
        self.forwarder_conveyances.build(:conveyance_id => conveyance_id)
      end
    end
  end
  
  def destroy_unselected_forwarder_conveyances
    @conveyances_ids ||= []
    forwarder_conveyances.each{ |forwarder_conveyance| forwarder_conveyance.destroy() unless @conveyances_ids.detect{|conveyance_id| conveyance_id == forwarder_conveyance.conveyance_id} }
  end
  
  def departure_attributes=(departures_attributes)
    departures_attributes.each do |attributes|
      if attributes["id"].blank?
        departures.build(attributes)
      else
        departure = departures.detect{ |d| d.id == attributes["id"].to_i }
        departure.attributes = attributes
        (departure.hidden = true) if attributes["should_hide"] == "1"
      end
    end
  end
  
  def save_departures
    departures.each{ |departure| departure.should_destroy? ? departure.destroy() : departure.save(false)}
  end
  
  def can_be_destroyed?
#    quotations.empty?
    true
  end
end

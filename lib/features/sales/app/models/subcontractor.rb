class Subcontractor < Third
  has_permissions :as_business_object
  has_contacts # please dont put in third.rb because has_contacts defines some routes and needs to know this class name
  has_address :address
  
  has_one :iban, :as => :has_iban
  belongs_to :activity_sector_reference
  
  # for pagination : number of instances by index page
  SUBCONTRACTORS_PER_PAGE = 15
  
  named_scope :activates, :conditions => {:activated => true}
  
  validates_format_of :siret_number, :with => /^[0-9]{14}$/, :message => "Le numéro SIRET doit comporter 14 chiffres"
  validates_uniqueness_of :name, :siret_number # don't put that in third.rb because validation should be only for customer (and not all thirds)
  validates_presence_of :activity_sector_reference_id
  validates_presence_of :activity_sector_reference, :if => :activity_sector_reference_id
  
  after_save :save_iban

  def iban_attributes=(iban_attributes)
    if iban_attributes[:id].blank?
      self.iban = build_iban(iban_attributes)
    else
      self.iban.attributes = iban_attributes
    end
  end

  def save_iban
    iban.save if iban
  end
end

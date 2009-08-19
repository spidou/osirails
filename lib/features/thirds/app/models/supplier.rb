class Supplier < Third
  # Permissions
  has_permissions :as_business_object

  # Relationships
  has_one :iban, :as => :has_iban

  # Validations
  validates_uniqueness_of :name, :siret_number
  
  # for pagination : number of instances by index page
  SUPPLIERS_PER_PAGE = 15

  # Name Scope
  named_scope :activates, :conditions => {:activated => true}

  after_update :save_iban

  def iban_attributes=(iban_attributes)
    if iban_attributes[:id].blank?
      self.iban = build_iban(iban_attributes)
    else
      self.iban.attributes = iban_attributes
    end
  end

  def save_iban
    iban.save
  end
end

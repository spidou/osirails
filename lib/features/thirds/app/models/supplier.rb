class Supplier < Third  
  has_one :iban, :as => :has_iban
  
  validates_uniqueness_of :name, :siret_number
  
  # Name Scope
  named_scope :activates, :conditions => {:activated => true}
  
  after_update :save_iban
  
  has_documents :test_a_supprimer
  
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
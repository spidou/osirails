class Supplier < Third  
  has_one :iban, :as => :has_iban
  
  validates_uniqueness_of :name, :siret_number
  
  # Name Scope
  named_scope :activates, :conditions => {:activated => true}
  
end
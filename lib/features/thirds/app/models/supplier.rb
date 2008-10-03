class Supplier < Third  
  has_one :iban, :as => :has_iban
  
  # Name Scope
  named_scope :activates, :conditions => {:activated => true}
  
end
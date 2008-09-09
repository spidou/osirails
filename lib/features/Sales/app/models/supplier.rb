class Supplier < Third  
  has_one :iban, :as => :has_iban
  acts_as_file
end
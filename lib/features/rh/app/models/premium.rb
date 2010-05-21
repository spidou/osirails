class Premium < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :employee 
  validates_format_of :amount , :with => /^[1-9]+(\d)*((\x2E)(\d)*)+$/, :message => "Le montant de la prime doit être un nombre"
end

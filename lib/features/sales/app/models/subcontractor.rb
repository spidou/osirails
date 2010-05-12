class Subcontractor < Supplier
  has_permissions :as_business_object
  has_contacts # please dont put in third.rb because has_contacts defines some routes and needs to know this class name
  has_address :address
  
  SUBCONTRACTORS_PER_PAGE = 15
end

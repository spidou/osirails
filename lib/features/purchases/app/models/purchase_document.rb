class PurchaseDocument < ActiveRecord::Base
  
  has_permissions :as_business_object
  
  has_one :parcel
  
  has_attached_file :delivery_document, 
                  :styles => { :thumb => "120x120" },
                  :path   => ":rails_root/assets/purchases/parcel/:parcel_id/delivery_documents/:id.:style",
                  :url    => "/delivery_document/:id.:extension"
end

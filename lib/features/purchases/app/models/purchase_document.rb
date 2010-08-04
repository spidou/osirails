class PurchaseDocument < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_attached_file :purchase_document, 
                    :styles => { :thumb => "120x120" },
                    :path   => ":rails_root/assets/purchases/:id/documents/:id.:extension",
                    :url    => "/purchases/:id/documents/:id.:extension"

  validates_attachment_presence :purchase_document
  validates_attachment_size     :purchase_document, :less_than => 5.megabytes 
end

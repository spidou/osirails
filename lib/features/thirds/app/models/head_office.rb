class HeadOffice < Establishment
  has_contacts
  
  journalize :attributes    => [ :name, :establishment_type_id, :activity_sector_reference_id, :siret_number, :activated, :hidden ],
             :subresources  => [ :address, :phone, :fax, :contacts, :documents ],
             :attachments   => :logo
  
  has_search_index :only_attributes => [:name, :activated, :siret_number],
                   :additional_attributes => {:full_address => :string},
                   :only_relationships => [:customer, :activity_sector_reference, :establishment_type, :contacts, :address, :phone, :fax]
end

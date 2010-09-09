class HeadOffice < Establishment
  has_search_index :only_attributes => [:name, :activated, :siret_number],
                   :additional_attributes => {:full_address => :string},
                   :only_relationships => [:customer, :activity_sector_reference, :establishment_type, :contacts, :address, :phone, :fax],
                   :main_model => true
end

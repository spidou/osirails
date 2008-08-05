class EstablishmentType < Third
  has_one :address, :as => :has_address
  has_many :establishments
  has_many :contacts
end
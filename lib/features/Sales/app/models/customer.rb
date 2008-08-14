class Customer < Third
  has_many :establishments
  has_many :contacts, :as => :has_contact
end
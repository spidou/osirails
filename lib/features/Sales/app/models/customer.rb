class Customer < Third
  has_one :address, :as => :has_address
  belongs_to :activity_sector
  belongs_to :third_type
  has_many :establishments
  has_many :contacts
end
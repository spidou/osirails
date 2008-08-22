class Customer < Third
  has_many :establishments
  
  validates_presence_of :activity_sector_id
end
class Third < ActiveRecord::Base
  has_one :address, :as => :has_address
  belongs_to :activity_sector
  belongs_to :third_type
  has_many :establishments
  has_many :contacts
  
  validates_presence_of :name
  validates_numericality_of :siret_number, :only_integer => true
  validates_numericality_of :banking_informations, :only_integer => true
end
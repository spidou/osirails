class Contact < ActiveRecord::Base
  has_many :contact_numbers
  validates_presence_of :first_name
  
end
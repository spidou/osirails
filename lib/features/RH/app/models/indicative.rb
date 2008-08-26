class Indicative < ActiveRecord::Base
  has_many :numbers
  belongs_to :country
end
 

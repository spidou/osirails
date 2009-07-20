class NumberType < ActiveRecord::Base
  has_many :numbers

  # Validations
  validates_presence_of :name
  
  
  has_search_index  :only_attributes => ["id","name"],
                    :main_model => false
end

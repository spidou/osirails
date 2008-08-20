class Number < ActiveRecord::Base
  belongs_to :indicative
  belongs_to :number_type
  belongs_to :has_number, :polymorphic => true
  
  validates_format_of 'number',:with => /^[0-9]{9}$/, :message => " le numéro doit contenir 10 chiffres"
end
 

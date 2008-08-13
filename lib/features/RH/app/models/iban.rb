class Iban < ActiveRecord::Base
  belongs_to :has_iban, :polymorphic => true
  
  validates_format_of 'bank_code',:with => /^[0-9]{0,5}$/, :message => "Le code Bancaire doit contenir 5 chiffres"
  validates_format_of 'teller_code',:with => /^[0-9]{0,5}$/, :message => "Le code  guichet doit contenir 5 chiffres"
  validates_format_of 'account_number',:with => /^[0-9]{0,10}$/, :message => "le numéros de compte doit contenir 10 chiffres"
  validates_format_of 'key',:with => /^[0-9]{0,2}$/, :message => "La clée doit contenir 2 chiffres"
end  
 

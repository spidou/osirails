class Iban < ActiveRecord::Base
  belongs_to :has_iban, :polymorphic => true
  
  validates_format_of 'bank_code', :with => /^[0-9]{5}$/, :allow_blank => true # , :message => "Le code Bancaire doit contenir 5 chiffres"
  validates_format_of 'branch_code', :with => /^[0-9]{5}$/, :allow_blank => true #, :message => "Le code  guichet doit contenir 5 chiffres"
  validates_format_of 'account_number', :with => /^[0-9]{11}$/, :allow_blank => true #, :message => "le numéros de compte doit contenir 11 chiffres"
  validates_format_of 'key', :with => /^[0-9]{2}$/, :allow_blank => true #, :message => "La clée doit contenir 2 chiffres"
end  
 

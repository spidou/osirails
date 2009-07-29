class Iban < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :has_iban, :polymorphic => true
  
#  ########### 
#  Active theses validations (and deactive others) when in the ibans/_iban.html.erb view we have
#  a button 'Create an Iban', and when we click on it the Iban's form appears
#  and with another button 'Cancel' which will remove the form
#  
#  validates_presence_of 'bank_name'
#  validates_presence_of 'account_name'
#  validates_format_of 'bank_code', :with => /^[0-9]{5}$/
#  validates_format_of 'branch_code', :with => /^[0-9]{5}$/
#  validates_format_of 'account_number', :with => /^[0-9]{11}$/
#  validates_format_of 'key', :with => /^[0-9]{2}$/
#  ###########
  validates_format_of 'bank_code', :with => /^[0-9]{5}$/, :allow_blank => true # , :message => "Le code Bancaire doit contenir 5 chiffres"
  validates_format_of 'branch_code', :with => /^[0-9]{5}$/, :allow_blank => true #, :message => "Le code  guichet doit contenir 5 chiffres"
  validates_format_of 'account_number', :with => /^[0-9]{11}$/, :allow_blank => true #, :message => "le numéros de compte doit contenir 11 chiffres"
  validates_format_of 'key', :with => /^[0-9]{2}$/, :allow_blank => true #, :message => "La clée doit contenir 2 chiffres"
  
  has_search_index :only_attributes => ["account_name", "bank_name", "bank_code", "branch_code", "account_number", "key"]
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:bank_name] = "Nom de la banque :"
  @@form_labels[:bank_code] = "Code bancaire :"
  @@form_labels[:branch_code] = "Code guichet :"
  @@form_labels[:account_number] = "N&deg; de compte :"
  @@form_labels[:key] = "Cl&eacute; :"
  @@form_labels[:account_name] = "Nom du compte :"
end

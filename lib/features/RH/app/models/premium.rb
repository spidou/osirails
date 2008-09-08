class Premium < ActiveRecord::Base
  include Permissible
  
  belongs_to :employee 
  validates_format_of :premium , :with => /^[1-9]+(\d)*((\x2E)(\d)*)+$/ , :message => "le montant de la prime doit être un nombre"
end

class Premium < ActiveRecord::Base
  include Permissible
  
  belongs_to :employee 
  validates_format_of :premium , :with => /^[1-9]+(\d)*((\x2E)(\d)*)+$/ , :message => "le montant de la prime doit être un nombre"

  cattr_accessor :form_labels

  @@form_labels = Hash.new
  @@form_labels[:premium] = "Prime :"
  @@form_labels[:remark] = "Motif :" 
end

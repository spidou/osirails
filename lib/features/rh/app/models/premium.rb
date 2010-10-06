class Premium < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :employee 
  
  validates_numericality_of :amount
  
  validates_presence_of :date
  validates_presence_of :remark
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:amount] = "Montant :"
  @@form_labels[:remark] = "Motif :" 
end

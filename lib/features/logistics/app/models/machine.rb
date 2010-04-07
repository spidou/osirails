class Machine < Tool
  has_permissions :as_business_object
  
  has_documents :legal_paper, :invoice, :manual, :other
  
  cattr_accessor :form_labels
  @@form_labels = abstract_form_labels
end

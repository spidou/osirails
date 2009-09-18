class OtherTool < Tool
  has_permissions :as_business_object
  
  has_documents :legal_paper, :invoice, :manual, :other
end

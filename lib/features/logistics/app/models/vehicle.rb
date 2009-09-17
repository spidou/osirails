class Vehicle < Tool
  has_documents :legal_paper, :invoice, :manual, :other
  
  @@form_labels[:serial_number]  = "N° d'immatriculation :"
end

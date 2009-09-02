class Computer < Tool
  has_documents :legal_paper, :invoice, :manual, :other
end

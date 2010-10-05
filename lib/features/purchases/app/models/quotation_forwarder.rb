class QuotationForwarder < Third
  belongs_to :quotation
  belongs_to :forwarder
  
  validates_presence_of :forwarder_id
  validates_presence_of :forwarder, :if => :forwarder_id
end

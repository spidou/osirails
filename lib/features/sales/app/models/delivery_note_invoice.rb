class DeliveryNoteInvoice < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :invoice
end

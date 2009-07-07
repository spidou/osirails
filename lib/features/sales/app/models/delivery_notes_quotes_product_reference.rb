class DeliveryNotesQuotesProductReference < ActiveRecord::Base
  acts_as_list
  
  belongs_to :delivery_note
  belongs_to :quotes_product_reference
end

require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseDocumentTest < ActiveSupport::TestCase
  
  should_have_attached_file :purchase_document

  should_validate_attachment_presence :purchase_document
  should_validate_attachment_size     :purchase_document, :less_than => 5.megabytes
end

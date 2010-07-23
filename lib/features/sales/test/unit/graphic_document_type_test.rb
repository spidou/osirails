require File.dirname(__FILE__) + '/../sales_test'

class GraphicDocumentTypeTest < ActiveSupport::TestCase
  should_have_many :graphic_documents
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
end

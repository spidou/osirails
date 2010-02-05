require 'test/test_helper'

class GraphicDocumentTypeTest < ActiveSupport::TestCase
  should_have_many :graphic_documents
  
  should_validate_presence_of :name
  
  context "A graphic document type" do
    setup do  
      @gdt = graphic_document_types(:normal)
      flunk "@gdt should be valid to continue" unless @gdt.valid?
    end
    
    subject { @gdt }
    
    should_validate_uniqueness_of :name
  end
end

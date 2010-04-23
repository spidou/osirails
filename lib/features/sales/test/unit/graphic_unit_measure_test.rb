require 'test/test_helper'

class GraphicUnitMeasureTest < ActiveSupport::TestCase
  should_have_many :graphic_items
  
  should_validate_presence_of :name, :symbol
  
  context "A graphic unit measure" do
    setup do  
      @gum = graphic_unit_measures(:millimeter)
      flunk "@gum should be valid" unless @gum.valid?
    end
    
    subject { @gum }
    
    should_validate_uniqueness_of :name, :symbol
  end
end

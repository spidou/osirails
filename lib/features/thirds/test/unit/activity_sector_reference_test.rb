require File.dirname(__FILE__) + '/../thirds_test'

class ActivitySectorReferenceTest < ActiveSupport::TestCase
  should_belong_to :activity_sector, :custom_activity_sector
  
  should_validate_presence_of :code
  should_validate_presence_of :activity_sector, :with_foreign_key => :default
  
  should_validate_uniqueness_of :code
  
  should_allow_values_for     :code, "01.01Z", "99.99A"
  should_not_allow_values_for :code, nil, "", "1", "0101Z", "01.01"
  
  context "An activity sector reference" do
    setup do
      @activity_sector_reference = ActivitySectorReference.new
    end
    
    should "always store an uppercase code" do
      @activity_sector_reference.code = "01.01z"
      assert_equal "01.01Z", @activity_sector_reference.code
    end
  end
  
  context "An activity sector reference with a custom_activity_sector" do
    setup do
      @activity_sector_reference = activity_sector_references(:ref1)
      flunk "@activity_sector_reference should have a custom_activity_sector" unless @activity_sector_reference.custom_activity_sector
    end
    
    teardown do
      @activity_sector_reference = nil
    end
    
    should "get custom_activity_sector" do
      assert_equal @activity_sector_reference.custom_activity_sector, @activity_sector_reference.get_activity_sector
    end
  end
  
  context "An activity sector reference without a custom_activity_sector" do
    setup do
      @activity_sector_reference = activity_sector_references(:ref2)
      flunk "@activity_sector_reference should NOT have a custom_activity_sector" if @activity_sector_reference.custom_activity_sector
    end
    
    teardown do
      @activity_sector_reference = nil
    end
    
    should "get activity_sector" do
      assert_equal @activity_sector_reference.activity_sector, @activity_sector_reference.get_activity_sector
    end
  end
end

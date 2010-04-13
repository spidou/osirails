require 'test/test_helper'

class ActivitySectorReferenceTest < Test::Unit::TestCase
  should_belong_to :activity_sector, :custom_activity_sector
  
  context "with a custom_activity_sector" do
    setup do
      @asr = activity_sector_references(:ref1)
    end
    
    teardown do
      @asr = nil
    end
    
    should "get custom_activity_sector" do
      assert_equal @asr.custom_activity_sector, @asr.get_activity_sector
    end
  end
  
  context "without a custom_activity_sector" do
    setup do
      @asr = activity_sector_references(:ref2)
    end
    
    teardown do
      @asr = nil
    end
    
    should "get activity_sector" do
      assert_equal @asr.activity_sector, @asr.get_activity_sector
    end
  end
  
end

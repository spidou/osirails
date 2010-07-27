require File.dirname(__FILE__) + '/../sales_test'

class DunningTest < ActiveSupport::TestCase
  should_belong_to :has_dunning, :creator, :dunning_sending_method, :cancelled_by
  
  should_validate_presence_of :date, :comment, :has_dunning_type
  should_validate_presence_of :dunning_sending_method, :creator, :has_dunning, :with_foreign_key => :default
  
  should_have_named_scope :actives, :conditions => ["cancelled_at is NULL"]
  should_have_named_scope :cancelled, :conditions => ["cancelled_at IS NOT NULL"]
  
  #TODO
  #validates_date :date, :on_or_after          => Proc.new {|n| n.has_dunning.sended_on if n.has_dunning},
  #                      :on_or_after_message  => "ne doit pas être AVANT la date d'envoi au client&#160;(%s)",
  #                      :on_or_before         => Proc.new { Date.today },
  #                      :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
  
  context "A new dunning without has_dunning" do
    setup do
      sample = create_default_dunning
      @dunning = Dunning.new(sample.attributes)
      @dunning.has_dunning = nil
    end
    
    teardown do
      @dunning = nil
    end
    
    should "not be valid" do
      assert !@dunning.valid?
      assert @dunning.errors.on(:has_dunning)
    end
    
    should "not be able to be added" do
      assert !@dunning.can_be_added?
    end
    
    should "not be cancelled" do
      assert !@dunning.was_cancelled?
    end
    
    should "not be able to be cancelled" do
      assert !@dunning.can_be_cancelled?
    end
    
    should "fail to cancel" do
      assert !@dunning.cancel(users(:sales_user))
      assert !@dunning.was_cancelled?
    end
  end
  
  context "A new dunning with a sended has_dunning" do
  
    setup do
      sample   = create_default_dunning
      @dunning = Dunning.new(sample.attributes)
      @dunning.has_dunning = sample.has_dunning
    end
    
    teardown do
      @dunning = nil
    end
    
    should "be valid" do
      assert @dunning.valid?
    end
    
    should "be able to be added" do
      assert @dunning.can_be_added?
    end
    
    should "not be able to be destroyed" do
      assert !@dunning.can_be_destroyed?
      assert !@dunning.destroy
    end
    
    should "not be cancelled" do
      assert !@dunning.was_cancelled?
    end
    
    should "not be able to be cancelled" do
      assert !@dunning.can_be_cancelled?
    end
    
    should "fail to cancel" do
      assert !@dunning.cancel(users(:sales_user))
      assert !@dunning.was_cancelled?
    end
  end
  
  context "A new dunning with a not sended has_dunning" do
  
    setup do
      @dunning = Dunning.new(create_default_dunning.attributes)
      @dunning.has_dunning = create_default_press_proof
    end
    
    teardown do
      @dunning = nil
    end
    
    should "not be valid" do
      assert !@dunning.valid?
      assert @dunning.errors.on(:has_dunning)
    end
    
    should "not be able to be added" do
      assert !@dunning.can_be_added?
    end
    
    should "not be cancelled" do
      assert !@dunning.was_cancelled?
    end
    
    should "not be able to be cancelled" do
      assert !@dunning.can_be_cancelled?
    end
    
    should "fail to cancel" do
      assert !@dunning.cancel(users(:sales_user))
      assert !@dunning.was_cancelled?
    end
    
    should "have has_dunning invalid" do
      @dunning.valid?
      assert @dunning.errors.invalid?(:has_dunning)
    end
    
  end
  
  context "A valid dunning" do
    setup do
      @dunning = create_default_dunning
    end
    
    teardown do
      @dunning = nil
    end
    
    should "not be cancelled" do
      assert !@dunning.was_cancelled?
    end
       
    should "be able to be cancelled" do
      assert @dunning.can_be_cancelled?
    end
     
    should "succeed to cancel" do
      assert @dunning.cancel(users(:sales_user))
      assert @dunning.was_cancelled?
    end
  end
  
  context "A cancelled dunning" do
    
    setup do
      @dunning = create_default_dunning
      @dunning.cancel(users(:sales_user))
    end
    
    teardown do
      @dunning = nil
    end
    
    should "be cancelled" do
      assert @dunning.was_cancelled?
    end
    
    [:date, :comment, :dunning_sending_method_id, :creator_id, :has_dunning_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@dunning.errors.invalid?(attribute)
        
        @dunning.send("#{attribute.to_s}=", nil)
        @dunning.valid?
        assert @dunning.errors.invalid?(attribute)
      end
    end
    
    should "not be able to be destroyed" do
      assert !@dunning.can_be_destroyed?
      
      assert !@dunning.destroy
      assert !Dunning.find(@dunning.id).nil?
    end
  end
end

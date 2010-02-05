require 'test/test_helper'
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
  
  context "A new dunning with a sended has_dunning" do
  
    setup do
      @dunning = Dunning.new(create_default_dunning.attributes)
      @dunning.valid?
    end
    
    teardown do
      @dunning = nil
    end
    
    should "be able de to be edited" do
      assert @dunning.can_be_edited?
    end
    
    should "not be able to be destroyed" do
      assert !@dunning.can_be_destroyed?
      assert !@dunning.destroy
    end
  end
  
  context "A new dunning with a not sended has_dunning" do
  
    setup do
      @dunning = Dunning.new(create_default_dunning.attributes)
      @dunning.has_dunning = create_default_press_proof
      @dunning.valid?
    end
    
    teardown do
      @dunning = nil
    end
    
    should "have has_dunning invalid" do
      assert @dunning.errors.invalid?(:has_dunning)
    end
    
  end
  
  context "A cancelled dunning" do
    
    setup do
      @dunning = create_default_dunning
      @dunning.valid?
    end
    
    teardown do
      @dunning = nil
    end
    
    [:date, :comment, :dunning_sending_method_id, :creator_id, :has_dunning_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@dunning.errors.invalid?(attribute)
        
        @dunning.send("#{attribute.to_s}=", nil)
        @dunning.valid?
        assert @dunning.errors.invalid?(attribute)
      end
    end
    
        
    should "not be able de to be edited" do
      assert !@dunning.can_be_edited?
    end
    
    should "not be able to be destroyed" do
      assert !@dunning.can_be_destroyed?
      
      assert !@dunning.destroy
      assert !Dunning.find(@dunning.id).nil?
    end
  end
end

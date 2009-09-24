require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class InterventionTest < ActiveSupport::TestCase
  
  def setup
    @order = create_default_order
    @signed_quote = create_signed_quote_for(@order)
    @delivery_note = create_valid_delivery_note_for(@order)
  end
  
  def teardown
    @order = @signed_quote = @delivery_note = @intervention = nil
  end
  
  def test_presence_of_delivery_note
    build_default_intervention
    
    intervention = Intervention.new
    intervention.valid?
    assert intervention.errors.invalid?(:delivery_note), "delivery_note should NOT be valid because it's nil"
    
    assert !@intervention.errors.invalid?(:delivery_note), "delivery_note should be valid #{@intervention.delivery_note.errors.full_messages}"
  end
  
  def test_presence_of_on_site
    build_default_intervention
    
    assert @intervention.errors.invalid?(:on_site), "on_site should NOT be valid because it's nil"
    
    true_values = [ true, "true", "1", 1 ]
    true_values.each do |v|
      @intervention.on_site = v
      assert @intervention.on_site, "on_site should be true (#{v.inspect})"
      @intervention.valid?
      assert !@intervention.errors.invalid?(:on_site), "on_site should be valid"
    end
    
    false_values = [ false, "false", "0", 0, "anything else" ]
    false_values.each do |v|
      @intervention.on_site = v
      assert !@intervention.on_site, "on_site should be false (#{v.inspect})"
      @intervention.valid?
      assert !@intervention.errors.invalid?(:on_site), "on_site should be valid"
    end
  end
  
  def test_presence_of_scheduled_delivery_at
    build_default_intervention
    
    assert @intervention.errors.invalid?(:scheduled_delivery_at), "scheduled_delivery_at should NOT be valid because it's nil"
    
    @intervention.scheduled_delivery_at = Time.now
    @intervention.valid?
    assert !@intervention.errors.invalid?(:scheduled_delivery_at), "scheduled_delivery_at should be valid"
  end
  
  def test_validity_of_scheduled_delivery_at
    #TODO
  end
  
  def test_presence_of_delivered_for_new_record
    build_default_intervention
    
    assert !@intervention.errors.invalid?(:delivered), "delivered should be valid"
  end
  
  def test_presence_of_delivered_for_existing_record
    @intervention = create_valid_intervention_for(@delivery_note)
    @intervention.valid?
    assert @intervention.errors.invalid?(:delivered), "delivered should NOT be valid because it should NOT be nil for existing record"
    
    true_values = [ true, "true", "1", 1 ]
    true_values.each do |v|
      @intervention.delivered = v
      assert @intervention.delivered, "delivered should be true (#{v.inspect})"
      @intervention.valid?
      assert !@intervention.errors.invalid?(:delivered), "delivered should be valid"
    end
    
    false_values = [ false, "false", "0", 0, "anything else" ]
    false_values.each do |v|
      @intervention.delivered = v
      assert !@intervention.delivered, "delivered should be false (#{v.inspect})"
      @intervention.valid?
      assert !@intervention.errors.invalid?(:delivered), "delivered should be valid"
    end
  end
  
  def test_presence_of_comments_for_new_record
    build_default_intervention
    
    assert !@intervention.errors.invalid?(:comments), "comments should be valid"
  end
  
  def test_presence_of_comments_for_existing_record
    @intervention = create_valid_intervention_for(@delivery_note)
    
    # when delivered = false
    @intervention.delivered = false
    @intervention.comments = ""
    @intervention.valid?
    assert @intervention.errors.invalid?(:comments), "comments should NOT be valid because it should NOT be blank if delivered = false"
    
    @intervention.comments = "some text"
    @intervention.valid?
    assert !@intervention.errors.invalid?(:comments), "comments should be valid"
    
    # when delivered = true
    @intervention.delivered = true
    @intervention.comments = ""
    @intervention.valid?
    assert !@intervention.errors.invalid?(:comments), "comments should be valid"
    
    @intervention.comments = "some text"
    @intervention.valid?
    assert !@intervention.errors.invalid?(:comments), "comments should be valid"
  end
  
  def test_presence_of_deliverers_when_not_on_site
    build_default_intervention
    
    # when on_site = false
    @intervention.on_site = false
    @intervention.valid?
    assert !@intervention.errors.invalid?(:deliverers), "deliverers should be valid"
    
    @intervention.deliverers << Employee.first
    assert_equal 1, @intervention.deliverers.size, "deliverers.size should be equal to 1"
    @intervention.valid?
    assert @intervention.errors.invalid?(:deliverers), "deliverers should NOT be valid because it's not empty and on_site = false"
  end
  
  def test_presence_of_deliverers_when_on_site
    build_default_intervention
    
    # when on_site = true
    @intervention.on_site = true
    @intervention.valid?
    assert @intervention.errors.invalid?(:deliverers), "deliverers should NOT be valid because it's empty and on_site = true"
    
    @intervention.deliverers << Employee.first
    assert_equal 1, @intervention.deliverers.size, "deliverers.size should be equal to 1"
    @intervention.valid?
    assert !@intervention.errors.invalid?(:deliverers), "deliverers should be valid"
  end
  
  def test_create_intervention
    @intervention = create_valid_intervention_for(@delivery_note)
    assert @intervention.instance_of?(Intervention), "@intervention should be an instance of Intervention"
    assert !@intervention.new_record?, "@intervention should NOT be a new record"
  end
  
  def test_update_intervention
    @intervention = create_valid_intervention_for(@delivery_note)
    @intervention.delivered = true
    @intervention.comments = "my special comment"
    assert @intervention.valid?, "@intervention should be valid"
    assert @intervention.save!, "@intervention should be saved"
  end
  
  private
    def build_default_intervention
      @intervention = @delivery_note.interventions.build
      @intervention.valid?
    end
  
end

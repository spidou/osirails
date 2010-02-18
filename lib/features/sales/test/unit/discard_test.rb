require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class DiscardTest < ActiveSupport::TestCase
  #TODO review all tests for discards
  
#  def setup
#    @order = create_default_order
#    @signed_quote = create_signed_quote_for(@order)
#    @delivery_note = create_valid_delivery_note_for(@order)
#    #@intervention = create_valid_delivery_intervention_for(@delivery_note)
#    #
#    #@intervention.delivered = true
#    #@intervention.comments = "my special comment"
#    flunk "@delivery_note should be valid to perform the following" unless @delivery_note.valid?
#    
#    @discard = Discard.new
#    @discard.valid?
#  end
#  
#  def teardown
#    @order = @signed_quote = @delivery_note = nil #@intervention = nil
#  end
#  
#  def test_presence_of_discard_type
#    assert @discard.errors.invalid?(:discard_type_id), "discard_type_id should NOT be valid because it's nil"
#    
#    @discard.discard_type_id = 0
#    @discard.valid?
#    assert !@discard.errors.invalid?(:discard_type_id), "discard_type_id should be valid"
#    assert @discard.errors.invalid?(:discard_type), "discard_type should NOT be valid because discard_type_id is wrong"
#    
#    @discard.discard_type_id = discard_types(:low_quality).id
#    @discard.valid?
#    assert !@discard.errors.invalid?(:discard_type_id), "discard_type_id should be valid"
#    assert !@discard.errors.invalid?(:discard_type), "discard_type should be valid"
#    
#    @discard.discard_type = discard_types(:low_quality)
#    @discard.valid?
#    assert !@discard.errors.invalid?(:discard_type_id), "discard_type_id should be valid"
#    assert !@discard.errors.invalid?(:discard_type), "discard_type should be valid"
#  end
#  
#  def test_presence_of_delivery_note_item
#    assert @discard.errors.invalid?(:delivery_note_item_id), "delivery_note_item_id should NOT be valid because it's nil"
#    
#    @discard.delivery_note_item_id = 0
#    @discard.valid?
#    assert !@discard.errors.invalid?(:delivery_note_item_id), "delivery_note_item_id should be valid"
#    assert @discard.errors.invalid?(:delivery_note_item), "delivery_note_item should NOT be valid because delivery_note_item_id is wrong"
#    
#    @discard.delivery_note_item_id = @delivery_note.delivery_note_items.first.id
#    @discard.valid?
#    assert !@discard.errors.invalid?(:delivery_note_item_id), "delivery_note_item_id should be valid"
#    assert !@discard.errors.invalid?(:delivery_note_item), "delivery_note_item should be valid"
#    
#    @discard.delivery_note_item = @delivery_note.delivery_note_items.first
#    @discard.valid?
#    assert !@discard.errors.invalid?(:delivery_note_item_id), "delivery_note_item_id should be valid"
#    assert !@discard.errors.invalid?(:delivery_note_item), "delivery_note_item should be valid"
#  end
#  
#  def test_presence_and_validity_of_quantity
#    assert !@discard.errors.invalid?(:quantity), "quantity should NOT be INVALID because quantity is not validated unless delivery_note_item is nil"
#    
#    @discard.delivery_note_item = @delivery_note.delivery_note_items.first
#    flunk "@discard should have a delivery_note_item to perform the following" unless @discard.delivery_note_item
#    
#    @reference_quantity = @discard.delivery_note_item.quantity
#    flunk "@reference_quantity should be greater than 0" unless @reference_quantity > 0
#    
#    @discard.valid?
#    assert @discard.errors.invalid?(:quantity), "quantity should NOT be valid because it's nil"
#    
#    @discard.quantity = "not a number"
#    @discard.valid?
#    assert @discard.errors.invalid?(:quantity), "quantity should NOT be valid because it's not a number"
#    
#    @discard.quantity = 0
#    @discard.valid?
#    assert @discard.errors.invalid?(:quantity), "quantity should NOT be valid because it should be greater than 0"
#    
#    @discard.quantity = -1
#    @discard.valid?
#    assert @discard.errors.invalid?(:quantity), "quantity should NOT be valid because it should be greater than 0"
#    
#    @discard.quantity = 1
#    @discard.valid?
#    assert !@discard.errors.invalid?(:quantity), "quantity should be valid because '#{@discard.quantity}' is greater than 0 and lesser than or equal to #{@reference_quantity}"
#    
#    @discard.quantity = @reference_quantity
#    @discard.valid?
#    assert !@discard.errors.invalid?(:quantity), "quantity should be valid because '#{@discard.quantity}' is greater than 0 and lesser than or equal to #{@reference_quantity}"
#    
#    @discard.quantity = @reference_quantity + 1
#    @discard.valid?
#    assert @discard.errors.invalid?(:quantity), "quantity should NOT be valid because '#{@discard.quantity}' is greater than #{@reference_quantity}"
#  end
#  
#  def test_presence_of_comments
#    assert @discard.errors.invalid?(:comments), "comments should NOT be valid because it's nil"
#    
#    @discard.comments = ""
#    @discard.valid?
#    assert @discard.errors.invalid?(:comments), "comments should NOT be valid because it's empty"
#    
#    @discard.comments = "some comments"
#    @discard.valid?
#    assert !@discard.errors.invalid?(:comments), "comments should be valid"
#  end
#  
#  def test_create_discard
#    @discard = create_valid_discard_for(@delivery_note)
#    assert @discard.instance_of?(Discard), "@discard should be an instance of Discard"
#    assert !@discard.new_record?, "@discard should NOT be a new record"
#  end
#  
#  def test_update_discard
#    #TODO
#  end
#  
#  def test_delete_discard
#    #TODO
#  end
  
end

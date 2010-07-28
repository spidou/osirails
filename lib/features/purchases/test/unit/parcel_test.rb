require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class ParcelTest < ActiveSupport::TestCase
  
  should_have_many :parcel_items
  should_have_many :purchase_order_supplies, :through => :parcel_items
  
  should_belong_to :delivery_document
  
  #TODO should_validate_date :processing_by_supplier_since
  #TODO should_validate_date :shipped_on
  #TODO should_validate_date :received_by_forwarder_on
  #TODO should_validate_date :received_on
   
  should_validate_presence_of :conveyance #, :if => :shipped?, :message => "Veuillez renseigner le transport."
  should_validate_presence_of :cancelled_comment#, :if => :cancelled_at, :message => "Veuillez indiquer la raison de l'annulation."
  
  context "A new parcel" do
    
    setup do
      @parcel = Parcel.new
    end
    
    
    
  end
end

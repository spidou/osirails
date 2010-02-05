require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class OrderTest < ActiveSupport::TestCase
  should_have_many :mockups, :graphic_documents
  
  subject { @order }

  def setup
    @order = Order.new
    @order.valid?
  end
  
  def teardown
    @order = nil
  end
  
  def test_presence_of_title
    assert @order.errors.invalid?(:title), "title should NOT be valid because it's nil"
    
    @order.title = ""
    @order.valid?
    assert @order.errors.invalid?(:title), "title should NOT be valid because it's empty"
    
    @order.title = "Title"
    @order.valid?
    assert !@order.errors.invalid?(:title), "title should be valid"
  end
  
  def test_presence_of_customer_needs
    assert @order.errors.invalid?(:customer_needs), "customer_needs should NOT be valid because it's nil"
    
    @order.customer_needs = ""
    @order.valid?
    assert @order.errors.invalid?(:customer_needs), "customer_needs should NOT be valid because it's empty"
    
    @order.customer_needs = "Customer Needs"
    @order.valid?
    assert !@order.errors.invalid?(:customer_needs), "customer_needs should be valid"
  end
  
  def test_presence_of_previsional_delivery
    assert @order.errors.invalid?(:previsional_delivery), "previsional_delivery should NOT be valid because it's nil"
    
    @order.previsional_delivery = Time.now + 10.days
    @order.valid?
    assert !@order.errors.invalid?(:previsional_delivery), "previsional_delivery should be valid"
    
    #TODO test if previsional_delivery is correct, if it's after order creation date), etc. (with validates_date)
  end
  
  def test_presence_of_society_activity_sector
    assert @order.errors.invalid?(:society_activity_sector_id), "society_activity_sector_id should NOT be valid because it's nil"
    
    @order.society_activity_sector_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:society_activity_sector_id), "society_activity_sector_id should be valid"
    assert @order.errors.invalid?(:society_activity_sector), "society_activity_sector should NOT be valid because society_activity_sector_id is wrong"
    
    @order.society_activity_sector_id = SocietyActivitySector.first.id
    @order.valid?
    assert !@order.errors.invalid?(:society_activity_sector_id), "society_activity_sector_id should be valid"
    assert !@order.errors.invalid?(:society_activity_sector), "society_activity_sector should be valid"
    
    @order.society_activity_sector = SocietyActivitySector.first
    @order.valid?
    assert !@order.errors.invalid?(:society_activity_sector_id), "society_activity_sector_id should be valid"
    assert !@order.errors.invalid?(:society_activity_sector), "society_activity_sector should be valid"
  end
  
  def test_presence_and_validity_of_order_type
    flunk "OrderType.count should be greater than 1 to perform the following, but was at #{OrderType.count}" unless OrderType.count > 1
    
    # when society_activity_sector is not yet selected
    assert !@order.errors.invalid?(:order_type_id), "order_type_id should be valid"
    assert !@order.errors.invalid?(:order_type), "order_type should be valid"
    
    # when society_activity_sector is selected
    society_activity_sector = SocietyActivitySector.first
    society_activity_sector.order_types << OrderType.first
    @order.society_activity_sector = society_activity_sector
    @order.valid?
    assert @order.errors.invalid?(:order_type_id), "order_type_id should NOT be valid because it's nil"
    
    # when order_type is in the list
    @order.order_type_id = OrderType.first.id
    @order.valid?
    assert !@order.errors.invalid?(:order_type_id), "order_type_id should be valid"
    assert !@order.errors.invalid?(:order_type), "order_type should be valid"
    
    @order.order_type = OrderType.first
    @order.valid?
    assert !@order.errors.invalid?(:order_type_id), "order_type_id should be valid"
    assert !@order.errors.invalid?(:order_type), "order_type should be valid"
    
    # when order_type is NOT in the list
    @order.order_type = OrderType.last
    @order.valid?
    assert @order.errors.invalid?(:order_type_id), "order_type_id should NOT be valid because it's NOT in the list"
    
    # when order_type_id is wrong
    @order.order_type_id = 0
    @order.valid?
    assert @order.errors.invalid?(:order_type_id), "order_type_id should NOT be valid because it's NOT in the list"
  end
  
  def test_presence_of_approaching
    assert @order.errors.invalid?(:approaching_id), "approaching_id should NOT be valid because it's nil"
    
    @order.approaching_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:approaching_id), "approaching_id should be valid"
    assert @order.errors.invalid?(:approaching), "approaching should NOT be valid because approaching_id is wrong"
    
    @order.approaching_id = Approaching.first.id
    @order.valid?
    assert !@order.errors.invalid?(:approaching_id), "approaching_id should be valid"
    assert !@order.errors.invalid?(:approaching), "approaching should be valid"
    
    @order.approaching = Approaching.first
    @order.valid?
    assert !@order.errors.invalid?(:approaching_id), "approaching_id should be valid"
    assert !@order.errors.invalid?(:approaching), "approaching should be valid"
  end
  
  def test_presence_of_commercial
    assert @order.errors.invalid?(:commercial_id), "commercial_id should NOT be valid because it's nil"
    
    @order.commercial_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:commercial_id), "commercial_id should be valid"
    assert @order.errors.invalid?(:commercial), "commercial should NOT be valid because commercial_id is wrong"
    
    @order.commercial_id = employees(:john_doe).id
    @order.valid?
    assert !@order.errors.invalid?(:commercial_id), "commercial_id should be valid"
    assert !@order.errors.invalid?(:commercial), "commercial should be valid"
    
    @order.commercial = employees(:john_doe)
    @order.valid?
    assert !@order.errors.invalid?(:commercial_id), "commercial_id should be valid"
    assert !@order.errors.invalid?(:commercial), "commercial should be valid"
    
    #TODO test if commercial is present in the accepted list of employees
  end
  
  def test_presence_of_creator
    assert @order.errors.invalid?(:user_id), "user_id should NOT be valid because it's nil"
    
    @order.user_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:user_id), "user_id should be valid"
    assert @order.errors.invalid?(:creator), "creator should NOT be valid because user_id is wrong"
    
    @order.user_id = users(:powerful_user).id
    @order.valid?
    assert !@order.errors.invalid?(:user_id), "user_id should be valid"
    assert !@order.errors.invalid?(:creator), "creator should be valid"
    
    @order.creator = users(:powerful_user)
    @order.valid?
    assert !@order.errors.invalid?(:user_id), "user_id should be valid"
    assert !@order.errors.invalid?(:creator), "creator should be valid"
  end
  
  def test_presence_of_customer
    assert @order.errors.invalid?(:customer_id), "customer_id should NOT be valid because it's nil"
    
    @order.customer_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:customer_id), "customer_id should be valid"
    assert @order.errors.invalid?(:customer), "customer should NOT be valid because customer_id is wrong"
    
    @order.customer = create_default_customer
    @order.valid?
    assert !@order.errors.invalid?(:customer_id), "customer_id should be valid"
    assert !@order.errors.invalid?(:customer), "customer should be valid"
  end
  
  def test_presence_of_contacts
    assert @order.errors.invalid?(:contact_ids), "contact_ids should NOT be valid because it's empty"
    
    @order.contacts << Contact.new # assuming Contact.new returns an invalid record by default
    @order.valid?
    assert !@order.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert @order.errors.invalid?(:contacts), "contacts should NOT be valid because it contains an invalid contact"
    
    @order.contacts = []
    @order.contact_ids << 0
    @order.valid?
    assert @order.errors.invalid?(:contact_ids), "contact_ids should NOT be valid because it contains a wrong contact ID"
    
    @order.contacts = []
    @order.contacts << contacts(:pierre_paul_jacques)
    @order.valid?
    assert !@order.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert @order.errors.invalid?(:contacts), "contact should NOT be valid because the contact is not present in the accepted list of contacts"
    
    customer = thirds(:first_customer)
    customer.establishments.first.contacts << contacts(:pierre_paul_jacques)
    customer.save
    @order.customer = customer
    @order.valid?
    assert !@order.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert !@order.errors.invalid?(:contacts), "contacts should be valid"
  end
  
  def test_presence_of_bill_to_address
    @invalid_address = Address.new # assuming Address.new returns an invalid record by default
    @valid_address   = Address.new(:street_name       => "Street Name",
                                   :country_name      => "Country",
                                   :city_name         => "City",
                                   :zip_code          => "01234",
                                   :has_address_type  => "Order",
                                   :has_address_key   => "bill_to_address")
                                 
    assert @order.errors.invalid?(:bill_to_address), "bill_to_address should NOT be a valid because it's nil"
    
    @order.bill_to_address = @invalid_address
    @order.valid?
    assert @order.errors.invalid?(:bill_to_address), "bill_to_address should NOT be valid"
    
    @order.bill_to_address = @valid_address
    @order.valid?
    assert !@order.errors.invalid?(:bill_to_address), "bill_to_address should be valid"
  end
  
  def test_validity_of_ship_to_addresses
    #TODO
  end
  
  def test_build_ship_to_address
    #TODO
  end
  
  def test_establishment_attributes
    #TODO
  end
  
  def test_ship_to_address_attributes
    #TODO
  end
  
  def test_save_ship_to_addresses
    #TODO
  end
  
  def test_save_ship_to_addresses_from_new_establishments
    #TODO
  end
  
  def test_validates_length_of_ship_to_addresses
    #TODO
  end
  
  def test_create_order
    @order = create_default_order
    assert @order.instance_of?(Order), "@order should be an instance of Order"
    assert !@order.new_record?, "@order should NOT be a new record"
  end
  
  context "generate a reference" do
    setup do
      @reference_owner       = create_default_order
      @other_reference_owner = create_default_order
    end
    
    include HasReferenceTest
  end
end

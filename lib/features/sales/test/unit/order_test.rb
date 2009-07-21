require 'test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class OrderTest < ActiveSupport::TestCase
  def setup
    create_default_order_types
    
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
  
  def test_presence_of_previsional_delivery
    assert @order.errors.invalid?(:previsional_delivery), "previsional_delivery should NOT be valid because it's nil"
    
    @order.previsional_delivery = Time.now + 10.days
    @order.valid?
    assert !@order.errors.invalid?(:previsional_delivery), "previsional_delivery should be valid"
    
    #TODO test if previsional_delivery is correct, if it's after order creation date), etc. (with validates_date)
  end
  
  def test_presence_of_order_type
    assert @order.errors.invalid?(:order_type_id), "order_type_id should NOT be valid because it's nil"
    
    @order.order_type_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:order_type_id), "order_type_id should be valid"
    assert @order.errors.invalid?(:order_type), "order_type should NOT be valid because order_type_id is wrong"
    
    @order.order_type_id = OrderType.first.id
    @order.valid?
    assert !@order.errors.invalid?(:order_type_id), "order_type_id should be valid"
    assert !@order.errors.invalid?(:order_type), "order_type should be valid"
    
    @order.order_type = OrderType.first
    @order.valid?
    assert !@order.errors.invalid?(:order_type_id), "order_type_id should be valid"
    assert !@order.errors.invalid?(:order_type), "order_type should be valid"
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
    
    @order.customer_id = thirds(:first_customer).id
    @order.valid?
    assert !@order.errors.invalid?(:customer_id), "customer_id should be valid"
    assert !@order.errors.invalid?(:customer), "customer should be valid"
    
    @order.customer = thirds(:first_customer)
    @order.valid?
    assert !@order.errors.invalid?(:customer_id), "customer_id should be valid"
    assert !@order.errors.invalid?(:customer), "customer should be valid"
  end
  
  def test_presence_of_establishment
    assert @order.errors.invalid?(:establishment_id), "establishment_id should NOT be valid because it's nil"
    
    @order.establishment_id = 0
    @order.valid?
    assert !@order.errors.invalid?(:establishment_id), "establishment_id should be valid"
    assert @order.errors.invalid?(:establishment), "establishment should NOT be valid because establishment_id is wrong"
    
    @order.establishment_id = establishments(:first_establishment).id
    @order.valid?
    assert !@order.errors.invalid?(:establishment_id), "establishment_id should be valid"
    assert !@order.errors.invalid?(:establishment), "establishment should be valid"
    
    @order.establishment = establishments(:first_establishment)
    @order.valid?
    assert !@order.errors.invalid?(:establishment_id), "establishment_id should be valid"
    assert !@order.errors.invalid?(:establishment), "establishment should be valid"
    
    #TODO test if establishment is present in the accepted list of establishments
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
    customer.contacts << contacts(:pierre_paul_jacques)
    customer.save
    @order.customer = customer
    @order.valid?
    assert !@order.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert !@order.errors.invalid?(:contacts), "contacts should be valid"
  end
  
  def test_create_order
    @order = create_default_order
    assert @order.instance_of?(Order), "@order should be an instance of Order"
    assert !@order.new_record?, "@order should NOT be a new record"
  end
end

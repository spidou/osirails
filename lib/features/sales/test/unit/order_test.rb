require File.dirname(__FILE__) + '/../sales_test'

class OrderTest < ActiveSupport::TestCase
  should_belong_to :society_activity_sector, :order_type, :customer, :commercial, :creator, :approaching
  
  # steps
  should_have_one :commercial_step, :pre_invoicing_step, :invoicing_step, :dependent => :nullify
  
  # quotes
  should_have_many :quotes
  should_have_one  :draft_quote, :pending_quote, :signed_quote
  
  # press_proofs
  should_have_many :press_proofs
  
  # delivery notes
  should_have_many :delivery_notes, :uncomplete_delivery_notes, :signed_delivery_notes
  
  # invoices
  should_have_many :invoices, :uncomplete_invoices
  
  should_have_many :ship_to_addresses, :end_products, :order_logs, :mockups, :graphic_documents
  
  #should_journalize :identifier_method => Proc.new {|o| "#{o.title} - #{o.reference}"} # don't work beacause Procs are not supported by this shoulda macro for the moment

  should_validate_presence_of :title, :previsional_delivery, :customer_needs, :bill_to_address
  should_validate_presence_of :customer, :society_activity_sector, :commercial, :approaching, :order_contact, :with_foreign_key => :default
  should_validate_presence_of :creator, :with_foreign_key => :user_id
  #validates_presence_of :order_type_id, :if => :society_activity_sector
  #validates_presence_of :order_type,    :if => :order_type_id
  
  #should_validate_presence_of :reference # don't work because a before_validation_on_create automatically generate a reference
  
  subject { @order }

  def setup
    @order = Order.new
    @order.valid?
  end
  
  def teardown
    @order = nil
  end
  
  def test_presence_and_validity_of_order_type
    flunk "OrderType.count should be greater than 1, but was at #{OrderType.count}" unless OrderType.count > 1
    
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
  
  context "An Order with all end_products referenced into a signed press_proof" do
    setup do
      @order      = create_default_order
      end_product = create_default_end_product(@order)
      press_proof = create_default_press_proof(@order, end_product)
      get_signed_press_proof(press_proof)
    end
    
    teardown do
      @order = nil
    end
    
    should "have a all end_product with signed press_proof" do
      assert @order.all_end_products_have_signed_press_proof?
    end
  end
  
  context "Thanks to 'has_reference', an order" do
    setup do
      @reference_owner       = create_default_order
      @other_reference_owner = create_default_order
    end
    
    include HasReferenceTest
  end
  
  context "Thanks to 'has_contact', an order" do
    setup do
      @contact_owner = create_default_order
      @contact_keys = [ :order_contact ]
    end
    
    subject { @contact_owner }
          
    should_belong_to :order_contact
    
    include HasContactTest
  end
end

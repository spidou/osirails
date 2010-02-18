require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class PressProofTest < ActiveSupport::TestCase
  should_belong_to :order, :product, :internal_actor, :creator, :document_sending_method, :revoked_by
  
  should_have_named_scope :actives, :conditions => ["status NOT IN (?)", [PressProof::STATUS_CANCELLED, PressProof::STATUS_REVOKED]]
  should_have_named_scope :signed_list, :conditions => ["status =?",[PressProof::STATUS_SIGNED]]
  
  should_have_many :press_proof_items
  should_have_many :graphic_item_versions
  should_have_many :dunnings

  should_validate_presence_of :order, :internal_actor, :creator, :with_foreign_key => :default
  
  context "A press proof not confirmed yet" do
    setup do
      @press_proof = create_default_press_proof
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
    should_allow_values_for     :status, nil, PressProof::STATUS_CONFIRMED, PressProof::STATUS_CANCELLED
    should_not_allow_values_for :status, PressProof::STATUS_SENDED, PressProof::STATUS_SIGNED, PressProof::STATUS_REVOKED
    
    should "validates_presence_of_press_proof_items_custom" do
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      @press_proof.press_proof_items = []
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
      
      @press_proof.press_proof_item_attributes = [{:graphic_item_version_id => create_default_mockup(@press_proof.order, @press_proof.product).current_version.id}]
      @press_proof.press_proof_items.first.should_destroy = 1;
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
    
    should "be able to be confirmed" do
      assert @press_proof.can_be_confirmed?
    end
    
    should "be confirmed" do
      confirm_press_proof(@press_proof)
      assert @press_proof.was_confirmed?
    end
        
    should "not be able to be sended" do
      assert !@press_proof.can_be_sended?
    end
    
    should "not be sended" do
      send_press_proof(@press_proof)
      assert !@press_proof.was_sended?
    end
    
    should "not be able to be signed" do
      assert !@press_proof.can_be_signed?
    end
    
    should "not be signed" do
      sign_press_proof(@press_proof)
      assert !@press_proof.was_signed?
    end
    
    should "not be able to be revoked" do
      assert !@press_proof.can_be_revoked?
    end
    
    should "not be revoked" do
      revoke_press_proof(@press_proof)
      assert !@press_proof.was_revoked?
    end
    
    should "not be able to be cancelled" do
      assert !@press_proof.can_be_cancelled?
    end
    
    should "not be cancelled" do
      cancel_press_proof(@press_proof)
      assert !@press_proof.was_cancelled?
    end
    
    should "be able to be edited" do
      assert @press_proof.can_be_edited?
    end
    
    should "be edited" do
      #TODO
    end
    
    should "be able to be destroyed" do
      assert @press_proof.can_be_destroyed?
    end
    
    should "be destroyed" do
      assert @press_proof.destroy
    end
    
    should "validate persistence of order_id" do
      assert !@press_proof.errors.invalid?(:order_id)
      @press_proof.order_id = nil
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:order_id)
    end
    
    should "validate persistence of product_id" do
      assert !@press_proof.errors.invalid?(:product_id)
      @press_proof.product_id = nil
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:product_id)
    end
  end
  
  
  context "A confirmed press proof" do
    setup do
      @press_proof = get_confirmed_press_proof
      flunk "@press_proof's status should be confirmed" unless @press_proof.was_confirmed?
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
    should_allow_values_for     :status, PressProof::STATUS_SENDED, PressProof::STATUS_CANCELLED
    should_not_allow_values_for :status, nil, PressProof::STATUS_CONFIRMED, PressProof::STATUS_SIGNED, PressProof::STATUS_REVOKED
    should_validate_presence_of :reference
#    TODO should_validate_date :confirmed_on, :equal_to => Proc.new { Date.today }
    
    should "not be able to be confirmed 'again'" do
      assert !@press_proof.can_be_confirmed?
    end
        
    should "be able to be sended" do
      assert @press_proof.can_be_sended?
    end
    
    should "be sended" do
      send_press_proof(@press_proof)
      assert @press_proof.was_sended?
    end
    
    should "not be able to be signed" do
      assert !@press_proof.can_be_signed?
    end
    
    should "not be signed" do
      sign_press_proof(@press_proof)
      assert !@press_proof.was_signed?
    end
    
    should "not be able to be revoked" do
      assert !@press_proof.can_be_revoked?
    end
    
    should "not be revoked" do
      revoke_press_proof(@press_proof)
      assert !@press_proof.was_revoked?
    end
    
    should "be able to be cancelled" do
      assert @press_proof.can_be_cancelled?
    end
    
    should "be cancelled" do
      cancel_press_proof(@press_proof)
      assert @press_proof.was_cancelled?
    end
    
    should "not be able to be edited" do
      assert !@press_proof.can_be_edited?
    end
    
    should "not be edited" do
      #TODO
    end
    
    should "not be able to be destroyed" do
      assert !@press_proof.can_be_destroyed?
    end
    
    should "not be destroyed" do
      assert !@press_proof.destroy
    end
    
    #### OPTIMIZE to avoid all that lines, use a macro like : should_validate_persistence_of :status, :references, etc...
    [:order_id, :product_id, :internal_actor_id, :creator_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", nil)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:confirmed_on].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", Date.tomorrow)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    should "validate persistence of press_proof_items" do
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
    ####
  end
  
  
  context "A sended press proof" do
    setup do
      @press_proof = get_sended_press_proof
      flunk "@press_proof's status should be sended" unless @press_proof.was_sended?
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
    should_allow_values_for     :status, PressProof::STATUS_SIGNED, PressProof::STATUS_CANCELLED
    should_not_allow_values_for :status, nil, PressProof::STATUS_SENDED, PressProof::STATUS_CONFIRMED, PressProof::STATUS_REVOKED
#    TODO should_validate_date :sended_on, :on_or_after => :confirmed_on, :on_or_after_message => "ne doit pas être AVANT la date de validation du Bon à tirer&#160;(%s)",
#                                          :on_or_before => Proc.new { Date.today }, :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
    
    should_validate_presence_of :document_sending_method, :with_foreign_key => :default
    
    should "not be able to be confirmed" do
      assert !@press_proof.can_be_confirmed?
    end
    
    should "not be confirmed" do
      confirm_press_proof(@press_proof)
      assert !@press_proof.was_confirmed?
    end
        
    should "not be able to be sended 'again'" do
      assert !@press_proof.can_be_sended?
    end
    
    should "be able to be signed" do
      assert @press_proof.can_be_signed?
    end
    
    should "be signed" do
      sign_press_proof(@press_proof)
      assert @press_proof.was_signed?
    end
    
    should "not be able to be revoked" do
      assert !@press_proof.can_be_revoked?
    end
    
    should "not be revoked" do
      revoke_press_proof(@press_proof)
      assert !@press_proof.was_revoked?
    end
    
    should "be able to be cancelled" do
      assert @press_proof.can_be_cancelled?
    end
    
    should "be cancelled" do
      cancel_press_proof(@press_proof)
      assert @press_proof.was_cancelled?
    end
    
    should "not be able to be edited" do
      assert !@press_proof.can_be_edited?
    end
    
    should "not be edited" do
      #TODO
    end
    
    should "not be able to be destroyed" do
      assert !@press_proof.can_be_destroyed?
    end
    
    should "not be destroyed" do
      assert !@press_proof.destroy
    end
    
    #### OPTIMIZE to avoid all that lines, use a macro like : should_validate_persistence_of :status, :references, etc...
    [:order_id, :product_id, :internal_actor_id, :creator_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", nil)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:confirmed_on, :sended_on].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", Date.tomorrow)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    should "validate persistence of press_proof_items" do
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
    ####
    
    context "which is linked with a product that is linked to an 'already signed' press proof" do
      setup do
        @other_press_proof = PressProof.new(:order_id          => @press_proof.order_id,
                                            :product_id        => @press_proof.product_id,
                                            :creator_id        => @press_proof.creator_id,
                                            :internal_actor_id => @press_proof.internal_actor_id,
                                            :press_proof_item_attributes =>  [{ :graphic_item_version_id => @press_proof.graphic_item_versions.first.id }] )
        
        flunk "press proof should be saved > #{@other_press_proof.errors.full_messages.join(', ')}" unless @other_press_proof.save
        
        flunk "@other_press_proof's status should be signed" unless get_signed_press_proof(@other_press_proof).was_signed?
      end
      
      teardown do
        @other_press_proof = nil
      end
      
      should "not be able to be signed" do
        assert !@press_proof.can_be_signed?
      end
      
      should "not be signed" do
        sign_press_proof(@press_proof)
        assert !@press_proof.was_signed?
      end
    end
  end
  
  
  context "A signed press proof" do
    setup do
      @press_proof = get_signed_press_proof
      flunk "@press_proof's status should be signed #{@press_proof.errors.inspect} " unless @press_proof.was_signed?
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
    should_allow_values_for     :status, PressProof::STATUS_REVOKED
    should_not_allow_values_for :status, nil, PressProof::STATUS_CONFIRMED, PressProof::STATUS_SENDED, PressProof::STATUS_SIGNED, PressProof::STATUS_CANCELLED
#    TODO should_validate_date :signed_on, :on_or_after => :confirmed_on, :on_or_after_message => "ne doit pas être AVANT la date de d'envoi du Bon à tirer&#160;(%s)",
#                                     :on_or_before => Proc.new { Date.today }, :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
    
    should_have_attached_file   :signed_press_proof
#    should_validate_attachment_content_type :signed_press_proof, :content_type => [ application/pdf ]
#    should_validate_attachment_size         :signed_press_proof, :less_than    => 2.megabytes
#    should_validate_attachment_presence     :signed_press_proof
    
    should "be valid with attachment presence" do
      assert !@press_proof.errors.invalid?(:signed_press_proof)
    end
    
    should "be invalid without signed_press_proof_file_name" do
      @press_proof.signed_press_proof.instance.signed_press_proof_file_name = nil
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:signed_press_proof)
    end
    
    should "be invalid without signed_press_proof_content_type" do
      @press_proof.signed_press_proof.instance.signed_press_proof_content_type = nil
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:signed_press_proof)
    end
    
    should "be invalid without signed_press_proof_file_size" do
      @press_proof.signed_press_proof.instance.signed_press_proof_file_size = nil
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:signed_press_proof)
    end
    
    should "be invalid without signed_press_proof" do
      @press_proof.signed_press_proof = nil
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:signed_press_proof)
    end
    
    should "not be able to be confirmed" do
      assert !@press_proof.can_be_confirmed?
    end
    
    should "not be confirmed" do
      confirm_press_proof(@press_proof)
      assert !@press_proof.was_confirmed?
    end
        
    should "not be able to be sended" do
      assert !@press_proof.can_be_sended?
    end
    
    should "not be sended" do
      send_press_proof(@press_proof)
      assert !@press_proof.was_sended?
    end
    
    should "not be able to be signed 'again'" do
      assert !@press_proof.can_be_signed?
    end
    
    should "be able to be revoked" do
      assert @press_proof.can_be_revoked?
    end
    
    should "be revoked" do
      revoke_press_proof(@press_proof)
      assert @press_proof.was_revoked?
    end
    
    should "not be able to be cancelled" do
      assert !@press_proof.can_be_cancelled?
    end
    
    should "not be cancelled" do
      cancel_press_proof(@press_proof)
      assert !@press_proof.was_cancelled?
    end
    
    should "not be able to be edited" do
      assert !@press_proof.can_be_edited?
    end
    
    should "not be edited" do
      #TODO
    end
    
    should "not be able to be destroyed" do
      assert !@press_proof.can_be_destroyed?
    end
    
    should "not be destroyed" do
      assert !@press_proof.destroy
    end
    
    #### OPTIMIZE to avoid all that lines, use a macro like : should_validate_persistence_of :status, :references, etc...
    [:order_id, :product_id, :internal_actor_id, :creator_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", nil)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:confirmed_on, :sended_on, :signed_on].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", Date.tomorrow)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    should "validate persistence of press_proof_items" do
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
    ####
  end
  
  
  context "A cancelled press proof" do
    setup do
      @press_proof = get_cancelled_press_proof
      flunk "@press_proof's status should be cancelled : #{@press_proof.errors.inspect} >>> #{@press_proof.status_was}" unless @press_proof.was_cancelled?
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
#    TODO should_validate_date :cancelled_on, :equal_to => Proc.new { Date.today }, :if => :cancelled?
    
    should "not be able to be confirmed" do
      assert !@press_proof.can_be_confirmed?
    end
    
    should "not be confirmed" do
      confirm_press_proof(@press_proof)
      assert !@press_proof.was_confirmed?
    end
        
    should "not be able to be sended" do
      assert !@press_proof.can_be_sended?
    end
    
    should "not be sended" do
      send_press_proof(@press_proof)
      assert !@press_proof.was_sended?
    end
    
    should "not be able to be signed" do
      assert !@press_proof.can_be_signed?
    end
    
    should "not be signed" do
      sign_press_proof(@press_proof)
      assert !@press_proof.was_signed?
    end
    
    should "not be able to be revoked" do
      assert !@press_proof.can_be_revoked?
    end
    
    should "not be revoked" do
      revoke_press_proof(@press_proof)
      assert !@press_proof.was_revoked?
    end
    
    should "not be able to be cancelled 'again'" do
      assert !@press_proof.can_be_cancelled?
    end
    
    should "not be able to be edited" do
      assert !@press_proof.can_be_edited?
    end
    
    should "not be edited" do
      #TODO
    end
    
    should "not be able to be destroyed" do
      assert !@press_proof.can_be_destroyed?
    end
    
    should "not be destroyed" do
      assert !@press_proof.destroy
    end
    
    #### OPTIMIZE to avoid all that lines, use a macro like : should_validate_persistence_of :status, :references, etc...
    [:order_id, :product_id, :internal_actor_id, :creator_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", nil)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:cancelled_on].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", Date.tomorrow)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:status].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", 100)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    #should "validate persistence of press_proof_items" do
    #  assert !@press_proof.errors.invalid?(:press_proof_items)
    #  
    #  graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
    #  @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
    #  @press_proof.valid?
    #  assert @press_proof.errors.invalid?(:press_proof_items)
    #end
    ####
  end
  
  
  context "A revoked press proof" do
    setup do
      @press_proof = get_revoked_press_proof
      flunk "@press_proof's status should be revoked into database" unless @press_proof.was_revoked?
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
#    TODO should_validate_date, :revoked_on, :equal_to => Proc.new { Date.today }
    should_validate_presence_of :revoked_comment
    should_validate_presence_of :revoked_by, :with_foreign_key => :default
    
    should "not be able to be confirmed" do
      assert !@press_proof.can_be_confirmed?
    end
    
    should "not be confirmed" do
      confirm_press_proof(@press_proof)
      assert !@press_proof.was_confirmed?
    end
        
    should "not be able to be sended" do
      assert !@press_proof.can_be_sended?
    end
    
    should "not be sended" do
      send_press_proof(@press_proof)
      assert !@press_proof.was_sended?
    end
    
    should "not be able to be signed" do
      assert !@press_proof.can_be_signed?
    end
    
    should "not be signed" do
      sign_press_proof(@press_proof)
      assert !@press_proof.was_signed?
    end
    
    should "not be able to be revoked 'again'" do
      assert !@press_proof.can_be_revoked?
    end
    
    should "not be able to be cancelled" do
      assert !@press_proof.can_be_cancelled?
    end
    
    should "not be cancelled" do
      cancel_press_proof(@press_proof)
      assert !@press_proof.was_cancelled?
    end
    
    should "not be able to be edited" do
      assert !@press_proof.can_be_edited?
    end
    
    should "not be edited" do
      #TODO
    end
    
    should "not be able to be destroyed" do
      assert !@press_proof.can_be_destroyed?
    end
    
    should "not be destroyed" do
      assert !@press_proof.destroy
    end
    
    # OPTIMIZE use a macro to test should_validate_persistence_of
    [:order_id, :product_id, :internal_actor_id, :creator_id].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", nil)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:confirmed_on, :sended_on, :signed_on, :revoked_on].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", Date.tomorrow)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    [:revoked_by_id, :revoked_comment, :status].each do |attribute|
      should "validate persistence of #{attribute.to_s}" do
        assert !@press_proof.errors.invalid?(attribute)
        @press_proof.send("#{attribute.to_s}=", 100)
        @press_proof.valid?
        assert @press_proof.errors.invalid?(attribute)
      end
    end
    
    should "validate persistence of press_proof_items" do
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
  end
  
  context "create a press proof" do
    setup do
      sample = create_default_press_proof
      @press_proof = PressProof.new( :order_id          => sample.order_id,
                                     :product_id        => sample.product_id,
                                     :creator_id        => sample.creator_id,
                                     :internal_actor_id => sample.internal_actor_id)
    end
    
    teardown do
      @press_proof = nil
    end
    
    subject { @press_proof }
    
    should_allow_values_for     :status, nil
    should_not_allow_values_for :status, PressProof::STATUS_CONFIRMED, PressProof::STATUS_SENDED, PressProof::STATUS_SIGNED, PressProof::STATUS_REVOKED, PressProof::STATUS_CANCELLED
    
    should "save only with graphic_item_versions as mockups" do
      graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
      @press_proof.valid?
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => create_default_graphic_document.current_version.id)
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
    
    should "save only with graphic_item_versions linked to the same product as the press_proof" do
      graphic_item_version = create_default_mockup(@press_proof.order, @press_proof.product).current_version
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => graphic_item_version.id)
      @press_proof.valid?
      assert !@press_proof.errors.invalid?(:press_proof_items)
      
      @press_proof.press_proof_items.build(:press_proof_id => @press_proof.id, :graphic_item_version_id => create_default_mockup.current_version.id)
      @press_proof.valid?
      assert @press_proof.errors.invalid?(:press_proof_items)
    end
    
  end
  
  private
  
  def get_confirmed_press_proof(press_proof = create_default_press_proof)
    press_proof.confirm
    press_proof
  end
  
  def get_sended_press_proof(press_proof = create_default_press_proof, date = Date.today)
    press_proof = get_confirmed_press_proof(press_proof) unless press_proof.can_be_sended?
    options     = {:sended_on => date, :document_sending_method_id => document_sending_methods(:courrier).id}
                   
    press_proof.send_to_customer(options)
    press_proof
  end
  
  def get_signed_press_proof(press_proof = create_default_press_proof, date = Date.today)
    press_proof = get_sended_press_proof(press_proof) unless press_proof.can_be_signed?
    options     = {:signed_on => date, :signed_press_proof => File.new(File.join(RAILS_ROOT, "test", "fixtures", "signed_press_proof.pdf"))}
                   
    press_proof.sign(options)
    press_proof
  end
  
  def get_cancelled_press_proof(press_proof = create_default_press_proof)
    press_proof = get_confirmed_press_proof(press_proof) unless press_proof.can_be_cancelled?
    
    press_proof.cancel
    press_proof
  end
  
  def get_revoked_press_proof(press_proof = create_default_press_proof, actor = users(:admin_user), comment = "comment", date = Date.today)
    press_proof = get_signed_press_proof(press_proof) unless press_proof.can_be_revoked?
    options = {:revoked_by_id => actor.id, :revoked_on => date, :revoked_comment => comment}
                
    press_proof.revoke(options)
    press_proof
  end
  
  
  
  def confirm_press_proof(p)
    p.confirm
    p
  end
  
  def send_press_proof(p)
    p.send_to_customer(:sended_on => Date.today, :document_sending_method_id => document_sending_methods(:courrier).id)
    p
  end
  
  def sign_press_proof(p)
    p.sign(:signed_on => Date.today, :signed_press_proof => File.new(File.join(RAILS_ROOT, "test", "fixtures", "signed_press_proof.pdf")))
    p
  end
  
  def cancel_press_proof(p)
    p.cancel
    p
  end
  
  def revoke_press_proof(p)
    p.revoke(:revoked_by_id => users(:admin_user).id, :revoked_on => Date.today, :revoked_comment => "comment")
    p
  end
end  

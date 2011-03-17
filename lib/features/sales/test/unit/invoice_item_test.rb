require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceItemTest < ActiveSupport::TestCase
  should_belong_to :invoice, :invoiceable
  
  # validates_persistence_of :invoiceable_id, :invoiceable_type
  
  should_journalize :attributes        => [:name, :description, :unit_price, :quantity, :vat]#,
                    #:identifier_method => Proc.new{ |i| "#{i.name} (x #{i.quantity})" }
  
  context "A valid and saved invoice_item" do
    setup do
      invoice = create_default_invoice
      @product = invoice.invoice_items.first
    end
    
    #FIXME ProductBaseTest has been deactivated because it uses "prizegiving=" to
    #      configure a specific prizegiving in a context, but invoice_item doesn't
    #      respond to this method
    #      
    #      We may use mock/stub object in ProductBaseTest instead
    #include ProductBaseTest
  end
end

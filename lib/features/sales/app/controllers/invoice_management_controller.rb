class InvoiceManagementController < ApplicationController
  helper :orders, :invoices
  
  # GET /invoice_management
  def index
    @invoices = Invoice.unpaid
  end
end

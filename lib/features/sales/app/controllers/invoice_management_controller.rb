class InvoiceManagementController < ApplicationController
  helper :orders, :invoices, :quotes, :delivery_notes
  query :invoices
  
  # GET /invoice_management
  def index
    build_query_for(:invoice_management_index)
  end
end

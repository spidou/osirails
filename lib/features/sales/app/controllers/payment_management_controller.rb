class PaymentManagementController < ApplicationController
  helper :orders, :invoices, :quotes, :delivery_notes
  query :invoices
  
  # GET /payment_management
  def index
    build_query_for(:payment_management_index)
  end
end
